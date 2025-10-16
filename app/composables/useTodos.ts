import { z } from 'zod'

// Todo schema with all fields
export const todoSchema = z.object({
  id: z.number(),
  created_at: z.string(),
  updated_at: z.string(),
  user_id: z.string().uuid(),
  company_id: z.string().uuid(),
  title: z.string().min(1, 'Title is required'),
  description: z.string().nullable(),
  completed: z.boolean().default(false),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).default('medium'),
  due_date: z.string().nullable(),
  category: z.string().nullable(),
  tags: z.array(z.string()).default([]),
  entity_type: z.string().nullable(),
  source_entity_id: z.string().uuid().nullable(),
  assigned_to: z.string().uuid().nullable(),
  order_index: z.number().default(0)
})

// Create todo schema (without auto-generated fields)
export const createTodoSchema = todoSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  user_id: true, // Will be set automatically
  company_id: true // Will be set automatically
})

// Update todo schema (all fields optional except id)
export const updateTodoSchema = todoSchema.partial().extend({
  id: z.number()
})

export type Todo = z.infer<typeof todoSchema>
export type CreateTodo = z.infer<typeof createTodoSchema>
export type UpdateTodo = z.infer<typeof updateTodoSchema>

export const useTodos = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Reactive state
  const todos = ref<Todo[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Get user's company_id (you'll need to adjust this based on your user_profiles table structure)
  const getUserCompanyId = async (): Promise<string | null> => {
    if (!user.value) return null

    try {
      const { data, error } = await client
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.value.id)
        .single()

      if (error) throw error
      return data?.company_id || null
    } catch (err) {
      console.error('Error getting user company ID:', err)
      return null
    }
  }

  // Fetch all todos for the user's company
  const fetchTodos = async (filters?: {
    completed?: boolean
    priority?: string
    category?: string
    assigned_to?: string
    entity_type?: string
  }) => {
    try {
      loading.value = true
      error.value = null

      let query = client
        .from('todos')
        .select('*')
        .order('order_index', { ascending: true })
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters?.completed !== undefined) {
        query = query.eq('completed', filters.completed)
      }
      if (filters?.priority) {
        query = query.eq('priority', filters.priority)
      }
      if (filters?.category) {
        query = query.eq('category', filters.category)
      }
      if (filters?.assigned_to) {
        query = query.eq('assigned_to', filters.assigned_to)
      }
      if (filters?.entity_type) {
        query = query.eq('entity_type', filters.entity_type)
      }

      const { data, error: supabaseError } = await query

      if (supabaseError) throw supabaseError

      // Validate and parse data
      todos.value = (data || []).map(item => {
        try {
          return todoSchema.parse(item)
        } catch (e) {
          console.error('Invalid todo data:', item, e)
          return null
        }
      }).filter(Boolean) as Todo[]

    } catch (err) {
      console.error('Error fetching todos:', err)
      error.value = 'Failed to load todos. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Create a new todo
  const createTodo = async (todoData: CreateTodo): Promise<Todo | null> => {
    try {
      if (!user.value) throw new Error('User not authenticated')

      const companyId = await getUserCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      // Validate input data
      const validatedData = createTodoSchema.parse(todoData)

      const { data, error: supabaseError } = await client
        .from('todos')
        .insert({
          ...validatedData,
          user_id: user.value.id,
          company_id: companyId
        })
        .select()
        .single()

      if (supabaseError) throw supabaseError

      const newTodo = todoSchema.parse(data)

      // Add to local state
      todos.value.unshift(newTodo)

      return newTodo
    } catch (err) {
      console.error('Error creating todo:', err)
      error.value = 'Failed to create todo. Please try again.'
      return null
    }
  }

  // Update a todo
  const updateTodo = async (todoData: UpdateTodo): Promise<Todo | null> => {
    try {
      // Validate input data
      const validatedData = updateTodoSchema.parse(todoData)
      const { id, ...updateFields } = validatedData

      const { data, error: supabaseError } = await client
        .from('todos')
        .update(updateFields)
        .eq('id', id)
        .select()
        .single()

      if (supabaseError) throw supabaseError

      const updatedTodo = todoSchema.parse(data)

      // Update local state
      const index = todos.value.findIndex(t => t.id === id)
      if (index !== -1) {
        todos.value[index] = updatedTodo
      }

      return updatedTodo
    } catch (err) {
      console.error('Error updating todo:', err)
      error.value = 'Failed to update todo. Please try again.'
      return null
    }
  }

  // Delete a todo
  const deleteTodo = async (id: number): Promise<boolean> => {
    try {
      const { error: supabaseError } = await client
        .from('todos')
        .delete()
        .eq('id', id)

      if (supabaseError) throw supabaseError

      // Remove from local state
      todos.value = todos.value.filter(t => t.id !== id)

      return true
    } catch (err) {
      console.error('Error deleting todo:', err)
      error.value = 'Failed to delete todo. Please try again.'
      return false
    }
  }

  // Toggle todo completion
  const toggleTodo = async (id: number): Promise<boolean> => {
    try {
      const todo = todos.value.find(t => t.id === id)
      if (!todo) throw new Error('Todo not found')

      const { data, error: supabaseError } = await client
        .from('todos')
        .update({ completed: !todo.completed })
        .eq('id', id)
        .select()
        .single()

      if (supabaseError) throw supabaseError

      const updatedTodo = todoSchema.parse(data)

      // Update local state
      const index = todos.value.findIndex(t => t.id === id)
      if (index !== -1) {
        todos.value[index] = updatedTodo
      }

      return true
    } catch (err) {
      console.error('Error toggling todo:', err)
      error.value = 'Failed to toggle todo. Please try again.'
      return false
    }
  }

  // Reorder todos
  const reorderTodos = async (todoIds: number[]): Promise<boolean> => {
    try {
      const updates = todoIds.map((id, index) => ({
        id,
        order_index: index
      }))

      const { error: supabaseError } = await client
        .from('todos')
        .upsert(updates)

      if (supabaseError) throw supabaseError

      // Update local state
      todos.value.sort((a, b) => {
        const aIndex = todoIds.indexOf(a.id)
        const bIndex = todoIds.indexOf(b.id)
        return aIndex - bIndex
      })

      return true
    } catch (err) {
      console.error('Error reordering todos:', err)
      error.value = 'Failed to reorder todos. Please try again.'
      return false
    }
  }

  // Get todos by category
  const getTodosByCategory = (category: string) => {
    return computed(() => todos.value.filter(todo => todo.category === category))
  }

  // Get todos by priority
  const getTodosByPriority = (priority: string) => {
    return computed(() => todos.value.filter(todo => todo.priority === priority))
  }

  // Get completed todos
  const completedTodos = computed(() => todos.value.filter(todo => todo.completed))

  // Get pending todos
  const pendingTodos = computed(() => todos.value.filter(todo => !todo.completed))

  // Get overdue todos
  const overdueTodos = computed(() => {
    const now = new Date()
    return todos.value.filter(todo =>
      !todo.completed &&
      todo.due_date &&
      new Date(todo.due_date) < now
    )
  })

  // Get todos due today
  const todosDueToday = computed(() => {
    const today = new Date().toDateString()
    return todos.value.filter(todo =>
      !todo.completed &&
      todo.due_date &&
      new Date(todo.due_date).toDateString() === today
    )
  })

  // Subscribe to real-time changes
  const subscribeToTodos = () => {
    if (!user.value) return null

    return client
      .channel('todos')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'todos'
        },
        (payload) => {
          console.log('Todo change received:', payload)
          // Refresh todos when changes occur
          fetchTodos()
        }
      )
      .subscribe()
  }

  return {
    // State
    todos: readonly(todos),
    loading: readonly(loading),
    error: readonly(error),

    // Actions
    fetchTodos,
    createTodo,
    updateTodo,
    deleteTodo,
    toggleTodo,
    reorderTodos,

    // Computed
    getTodosByCategory,
    getTodosByPriority,
    completedTodos,
    pendingTodos,
    overdueTodos,
    todosDueToday,

    // Real-time
    subscribeToTodos,

    // Utils
    getUserCompanyId
  }
}