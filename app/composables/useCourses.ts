import { z } from 'zod'

// Course schemas
export const courseSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string().nullable(),
  thumbnailUrl: z.string().nullable(),
  difficultyLevel: z.enum(['beginner', 'intermediate', 'advanced']).default('beginner'),
  durationHours: z.number().default(0),
  isPublished: z.boolean().default(false),
  isFeatured: z.boolean().default(false),
  category: z.string().nullable(),
  tags: z.array(z.string()).default([]),
  companyId: z.string(),
  createdBy: z.string(),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const lessonSchema = z.object({
  id: z.string(),
  courseId: z.string(),
  title: z.string(),
  description: z.string().nullable(),
  content: z.string().nullable(),
  lessonOrder: z.number(),
  durationMinutes: z.number().default(0),
  isPublished: z.boolean().default(false),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const lessonResourceSchema = z.object({
  id: z.string(),
  lessonId: z.string(),
  title: z.string(),
  resourceType: z.enum(['video', 'document', 'link', 'image']),
  url: z.string(),
  fileSize: z.number().nullable(),
  mimeType: z.string().nullable(),
  durationSeconds: z.number().nullable(),
  resourceOrder: z.number().default(0),
  createdAt: z.string()
})

export const userCourseProgressSchema = z.object({
  id: z.string(),
  userId: z.string(),
  courseId: z.string(),
  status: z.enum(['not_started', 'in_progress', 'completed', 'paused']).default('not_started'),
  progressPercentage: z.number().min(0).max(100).default(0),
  startedAt: z.string().nullable(),
  completedAt: z.string().nullable(),
  lastAccessedAt: z.string(),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const userLessonProgressSchema = z.object({
  id: z.string(),
  userId: z.string(),
  lessonId: z.string(),
  courseId: z.string(),
  status: z.enum(['not_started', 'in_progress', 'completed']).default('not_started'),
  timeSpentSeconds: z.number().default(0),
  completionPercentage: z.number().min(0).max(100).default(0),
  startedAt: z.string().nullable(),
  completedAt: z.string().nullable(),
  lastAccessedAt: z.string(),
  createdAt: z.string(),
  updatedAt: z.string()
})


export type Course = z.infer<typeof courseSchema>
export type Lesson = z.infer<typeof lessonSchema>
export type LessonResource = z.infer<typeof lessonResourceSchema>
export type UserCourseProgress = z.infer<typeof userCourseProgressSchema>
export type UserLessonProgress = z.infer<typeof userLessonProgressSchema>

export interface CourseFilters {
  category?: string
  difficultyLevel?: string
  isPublished?: boolean
  isFeatured?: boolean
  search?: string
}

export const useCourses = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Reactive state
  const courses = ref<Course[]>([])
  const currentCourse = ref<Course | null>(null)
  const lessons = ref<Lesson[]>([])
  const currentLesson = ref<Lesson | null>(null)
  const lessonResources = ref<LessonResource[]>([])
  const userProgress = ref<UserCourseProgress | null>(null)
  const lessonProgress = ref<UserLessonProgress[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Get user's company_id
  const getUserCompanyId = async (): Promise<string | null> => {
    if (!user.value) return null

    try {
      const { data, error } = await client
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.value.id)
        .single()

      if (error) {
        // If user profile doesn't exist, create one with default company
        if (error.code === 'PGRST116') {
          const { data: newProfile, error: createError } = await client
            .from('user_profiles')
            .insert({
              user_id: user.value.id,
              email: user.value.email,
              company_id: '550e8400-e29b-41d4-a716-446655440000' // Default demo company
            })
            .select('company_id')
            .single()

          if (createError) {
            console.error('Error creating user profile:', createError)
            return '550e8400-e29b-41d4-a716-446655440000' // Return default company ID
          }
          return newProfile?.company_id || '550e8400-e29b-41d4-a716-446655440000'
        }
        throw error
      }
      return data?.company_id || '550e8400-e29b-41d4-a716-446655440000'
    } catch (err) {
      console.error('Error getting user company ID:', err)
      return '550e8400-e29b-41d4-a716-446655440000' // Return default company ID as fallback
    }
  }

  // Fetch courses
  const fetchCourses = async (filters: CourseFilters = {}) => {
    try {
      loading.value = true
      error.value = null

      let query = client
        .from('courses')
        .select('*')
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.category) {
        query = query.eq('category', filters.category)
      }

      if (filters.difficultyLevel) {
        query = query.eq('difficulty_level', filters.difficultyLevel)
      }

      if (filters.isPublished !== undefined) {
        query = query.eq('is_published', filters.isPublished)
      }

      if (filters.isFeatured !== undefined) {
        query = query.eq('is_featured', filters.isFeatured)
      }

      if (filters.search) {
        query = query.or(`title.ilike.%${filters.search}%,description.ilike.%${filters.search}%`)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      courses.value = (data || []).map(item => courseSchema.parse({
        ...item,
        thumbnailUrl: item.thumbnail_url,
        difficultyLevel: item.difficulty_level,
        durationHours: item.duration_hours,
        isPublished: item.is_published,
        isFeatured: item.is_featured,
        companyId: item.company_id,
        createdBy: item.created_by,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))

    } catch (err) {
      console.error('Error fetching courses:', err)
      error.value = 'Failed to load courses. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Fetch course by ID
  const fetchCourse = async (courseId: string) => {
    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await client
        .from('courses')
        .select('*')
        .eq('id', courseId)
        .single()

      if (fetchError) throw fetchError

      currentCourse.value = courseSchema.parse({
        ...data,
        thumbnailUrl: data.thumbnail_url,
        difficultyLevel: data.difficulty_level,
        durationHours: data.duration_hours,
        isPublished: data.is_published,
        isFeatured: data.is_featured,
        companyId: data.company_id,
        createdBy: data.created_by,
        createdAt: data.created_at,
        updatedAt: data.updated_at
      })

    } catch (err) {
      console.error('Error fetching course:', err)
      error.value = 'Failed to load course. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Fetch lessons for a course
  const fetchLessons = async (courseId: string) => {
    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await client
        .from('lessons')
        .select('*')
        .eq('course_id', courseId)
        .eq('is_published', true)
        .order('lesson_order', { ascending: true })

      if (fetchError) throw fetchError

      lessons.value = (data || []).map(item => lessonSchema.parse({
        ...item,
        courseId: item.course_id,
        lessonOrder: item.lesson_order,
        durationMinutes: item.duration_minutes,
        isPublished: item.is_published,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))

    } catch (err) {
      console.error('Error fetching lessons:', err)
      error.value = 'Failed to load lessons. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Fetch lesson resources
  const fetchLessonResources = async (lessonId: string) => {
    try {
      const { data, error: fetchError } = await client
        .from('lesson_resources')
        .select('*')
        .eq('lesson_id', lessonId)
        .order('resource_order', { ascending: true })

      if (fetchError) throw fetchError

      lessonResources.value = (data || []).map(item => lessonResourceSchema.parse({
        ...item,
        lessonId: item.lesson_id,
        resourceType: item.resource_type,
        fileSize: item.file_size,
        mimeType: item.mime_type,
        durationSeconds: item.duration_seconds,
        resourceOrder: item.resource_order,
        createdAt: item.created_at
      }))

    } catch (err) {
      console.error('Error fetching lesson resources:', err)
      error.value = 'Failed to load lesson resources.'
    }
  }

  // Get user's course progress
  const fetchUserCourseProgress = async (courseId: string) => {
    if (!user.value) return

    try {
      const { data, error: fetchError } = await client
        .from('user_course_progress')
        .select('*')
        .eq('user_id', user.value.id)
        .eq('course_id', courseId)
        .single()

      if (fetchError && fetchError.code !== 'PGRST116') throw fetchError

      if (data) {
        userProgress.value = userCourseProgressSchema.parse({
          ...data,
          userId: data.user_id,
          courseId: data.course_id,
          progressPercentage: data.progress_percentage,
          startedAt: data.started_at,
          completedAt: data.completed_at,
          lastAccessedAt: data.last_accessed_at,
          createdAt: data.created_at,
          updatedAt: data.updated_at
        })
      } else {
        userProgress.value = null
      }

    } catch (err) {
      console.error('Error fetching user course progress:', err)
    }
  }

  // Start or update course progress
  const updateCourseProgress = async (courseId: string, status: string, progressPercentage?: number) => {
    if (!user.value) return

    try {
      const updateData: any = {
        user_id: user.value.id,
        course_id: courseId,
        status,
        last_accessed_at: new Date().toISOString()
      }

      if (progressPercentage !== undefined) {
        updateData.progress_percentage = progressPercentage
      }

      if (status === 'in_progress' && !userProgress.value?.startedAt) {
        updateData.started_at = new Date().toISOString()
      }

      if (status === 'completed') {
        updateData.completed_at = new Date().toISOString()
        updateData.progress_percentage = 100
      }

      const { data, error: upsertError } = await client
        .from('user_course_progress')
        .upsert(updateData, { onConflict: 'user_id,course_id' })
        .select()
        .single()

      if (upsertError) throw upsertError

      // Update local state
      await fetchUserCourseProgress(courseId)

    } catch (err) {
      console.error('Error updating course progress:', err)
      error.value = 'Failed to update progress.'
    }
  }

  // Update lesson progress
  const updateLessonProgress = async (lessonId: string, courseId: string, status: string, completionPercentage?: number) => {
    if (!user.value) return

    try {
      const updateData: any = {
        user_id: user.value.id,
        lesson_id: lessonId,
        course_id: courseId,
        status,
        last_accessed_at: new Date().toISOString()
      }

      if (completionPercentage !== undefined) {
        updateData.completion_percentage = completionPercentage
      }

      if (status === 'in_progress') {
        const existing = lessonProgress.value.find(p => p.lessonId === lessonId)
        if (!existing?.startedAt) {
          updateData.started_at = new Date().toISOString()
        }
      }

      if (status === 'completed') {
        updateData.completed_at = new Date().toISOString()
        updateData.completion_percentage = 100
      }

      const { error: upsertError } = await client
        .from('user_lesson_progress')
        .upsert(updateData, { onConflict: 'user_id,lesson_id' })

      if (upsertError) throw upsertError

      // Fetch updated lesson progress for the course
      await fetchLessonProgress(courseId)

      // Update overall course progress
      await calculateAndUpdateCourseProgress(courseId)

    } catch (err) {
      console.error('Error updating lesson progress:', err)
      error.value = 'Failed to update lesson progress.'
    }
  }

  // Fetch lesson progress for a course
  const fetchLessonProgress = async (courseId: string) => {
    if (!user.value) return

    try {
      const { data, error: fetchError } = await client
        .from('user_lesson_progress')
        .select('*')
        .eq('user_id', user.value.id)
        .eq('course_id', courseId)

      if (fetchError) throw fetchError

      lessonProgress.value = (data || []).map(item => userLessonProgressSchema.parse({
        ...item,
        userId: item.user_id,
        lessonId: item.lesson_id,
        courseId: item.course_id,
        timeSpentSeconds: item.time_spent_seconds,
        completionPercentage: item.completion_percentage,
        startedAt: item.started_at,
        completedAt: item.completed_at,
        lastAccessedAt: item.last_accessed_at,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))

    } catch (err) {
      console.error('Error fetching lesson progress:', err)
    }
  }

  // Calculate and update overall course progress
  const calculateAndUpdateCourseProgress = async (courseId: string) => {
    if (!user.value) return

    try {
      // Get all lessons for the course
      const { data: courseLessons, error: lessonsError } = await client
        .from('lessons')
        .select('id')
        .eq('course_id', courseId)
        .eq('is_published', true)

      if (lessonsError) throw lessonsError

      if (!courseLessons || courseLessons.length === 0) return

      // Get completed lessons count
      const completedLessons = lessonProgress.value.filter(
        p => p.courseId === courseId && p.status === 'completed'
      ).length

      const progressPercentage = Math.round((completedLessons / courseLessons.length) * 100)
      const newStatus = progressPercentage === 100 ? 'completed' :
                       progressPercentage > 0 ? 'in_progress' : 'not_started'

      await updateCourseProgress(courseId, newStatus, progressPercentage)

    } catch (err) {
      console.error('Error calculating course progress:', err)
    }
  }

  // Get lesson progress by lesson ID
  const getLessonProgress = (lessonId: string) => {
    return lessonProgress.value.find(p => p.lessonId === lessonId)
  }

  // Check if lesson is completed
  const isLessonCompleted = (lessonId: string) => {
    const progress = getLessonProgress(lessonId)
    return progress?.status === 'completed'
  }

  // Get next lesson
  const getNextLesson = (currentLessonOrder: number) => {
    return lessons.value.find(lesson => lesson.lessonOrder === currentLessonOrder + 1)
  }

  // Get previous lesson
  const getPreviousLesson = (currentLessonOrder: number) => {
    return lessons.value.find(lesson => lesson.lessonOrder === currentLessonOrder - 1)
  }

  return {
    // State
    courses: readonly(courses),
    currentCourse: readonly(currentCourse),
    lessons: readonly(lessons),
    currentLesson,
    lessonResources: readonly(lessonResources),
    userProgress: readonly(userProgress),
    lessonProgress: readonly(lessonProgress),
    loading: readonly(loading),
    error: readonly(error),

    // Actions
    fetchCourses,
    fetchCourse,
    fetchLessons,
    fetchLessonResources,
    fetchUserCourseProgress,
    fetchLessonProgress,
    updateCourseProgress,
    updateLessonProgress,
    calculateAndUpdateCourseProgress,

    // Utils
    getLessonProgress,
    isLessonCompleted,
    getNextLesson,
    getPreviousLesson,
    getUserCompanyId
  }
}