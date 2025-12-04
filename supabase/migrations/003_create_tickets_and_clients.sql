-- Create clients table (structure from production - managed by new migrations)
CREATE TABLE public.clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    company_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    contact_person VARCHAR(255),
    notes TEXT,
    status VARCHAR(50) DEFAULT 'active',
    user_id UUID,
    postal_code VARCHAR(20),
    city VARCHAR(100),
    street VARCHAR(255),
    house_number VARCHAR(50),
    ofp_client_id UUID,
    ekr_client_id UUID,
    CONSTRAINT clients_status_check CHECK (status = ANY (ARRAY['active'::VARCHAR, 'inactive'::VARCHAR, 'archived'::VARCHAR, 'prospect'::VARCHAR]::TEXT[]))
);

-- Add foreign key constraints for clients
ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create tickets table
CREATE TABLE public.tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    company_id UUID NOT NULL, -- Multi-tenant support
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL, -- Who created this ticket
    title VARCHAR(255) NOT NULL,
    description TEXT,
    client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
    client_name VARCHAR(255) NOT NULL, -- Denormalized for quick access
    category VARCHAR(50) DEFAULT 'technical' CHECK (category IN ('technical', 'contract', 'billing', 'maintenance')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('urgent', 'high', 'normal')),
    status VARCHAR(50) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    resolution TEXT,
    resolved_at TIMESTAMPTZ,
    ticket_number VARCHAR(50) UNIQUE, -- Auto-generated ticket number
    tags TEXT[] -- Array of tags
);

-- Create function to generate ticket numbers
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
    max_number INTEGER;
BEGIN
    -- Get the maximum ticket number for this year
    SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number FROM 9) AS INTEGER)), 0)
    INTO max_number
    FROM public.tickets
    WHERE ticket_number LIKE (EXTRACT(YEAR FROM NOW())::TEXT || '%');

    -- Generate new ticket number: YYYY-NNNN (e.g., 2024-0001)
    new_number := EXTRACT(YEAR FROM NOW())::TEXT || '-' || LPAD((max_number + 1)::TEXT, 4, '0');

    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to auto-generate ticket numbers
CREATE OR REPLACE FUNCTION set_ticket_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ticket_number IS NULL THEN
        NEW.ticket_number := generate_ticket_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_ticket_number_trigger
    BEFORE INSERT ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION set_ticket_number();

-- Add updated_at trigger for tickets
-- Note: clients trigger is in 496_add_functions_and_triggers.sql
CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for performance
-- Clients indexes
CREATE INDEX idx_clients_company_id ON public.clients(company_id);
CREATE INDEX idx_clients_name ON public.clients(name);
CREATE INDEX idx_clients_status ON public.clients(status);
CREATE INDEX idx_clients_ofp_client_id ON public.clients(ofp_client_id) WHERE ofp_client_id IS NOT NULL;
CREATE UNIQUE INDEX idx_clients_ofp_unique ON public.clients(ofp_client_id) WHERE ofp_client_id IS NOT NULL;
CREATE INDEX idx_clients_ekr_client_id ON public.clients(ekr_client_id) WHERE ekr_client_id IS NOT NULL;
CREATE UNIQUE INDEX idx_clients_ekr_unique ON public.clients(ekr_client_id) WHERE ekr_client_id IS NOT NULL;

-- Tickets indexes
CREATE INDEX idx_tickets_company_id ON public.tickets(company_id);
CREATE INDEX idx_tickets_client_id ON public.tickets(client_id);
CREATE INDEX idx_tickets_status ON public.tickets(status);
CREATE INDEX idx_tickets_priority ON public.tickets(priority);
CREATE INDEX idx_tickets_category ON public.tickets(category);
CREATE INDEX idx_tickets_created_at ON public.tickets(created_at);
CREATE INDEX idx_tickets_ticket_number ON public.tickets(ticket_number);

-- Enable Row Level Security
-- Note: clients RLS is enabled in 495_add_rls_policies.sql
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

-- RLS Policies for clients
-- Note: clients policies are in 495_add_rls_policies.sql

-- RLS Policies for tickets
CREATE POLICY "Users can view tickets from their company"
    ON public.tickets FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert tickets for their company"
    ON public.tickets FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
        AND user_id = auth.uid()
    );

CREATE POLICY "Users can update tickets from their company"
    ON public.tickets FOR UPDATE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete tickets from their company"
    ON public.tickets FOR DELETE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Grant permissions
GRANT ALL ON public.clients TO authenticated;
GRANT ALL ON public.tickets TO authenticated;

-- Note: Client seed data is in production seed migration, sample data removed
