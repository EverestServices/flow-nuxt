-- Create calendar_events table
CREATE TABLE public.calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) DEFAULT 'other' CHECK (type IN ('meeting', 'training', 'other', 'on-site-consultation', 'online-consultation', 'personal', 'holiday')),
    start_date DATE NOT NULL,
    start_time TIME,
    end_date DATE NOT NULL,
    end_time TIME,
    all_day BOOLEAN DEFAULT FALSE,
    visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'confidential')),
    notes TEXT,
    location VARCHAR(500),
    attendees TEXT[] DEFAULT '{}' -- Array of email addresses
);

-- Create function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at trigger for calendar_events
CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON public.calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for performance
CREATE INDEX idx_calendar_events_user_id ON public.calendar_events(user_id);
CREATE INDEX idx_calendar_events_start_date ON public.calendar_events(start_date);
CREATE INDEX idx_calendar_events_type ON public.calendar_events(type);
CREATE INDEX idx_calendar_events_visibility ON public.calendar_events(visibility);
CREATE INDEX idx_calendar_events_date_range ON public.calendar_events(start_date, end_date);

-- Enable Row Level Security
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies for calendar_events
CREATE POLICY "Users can view their own events"
    ON public.calendar_events FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can view public events from same company"
    ON public.calendar_events FOR SELECT
    USING (
        visibility = 'public'
        AND user_id IN (
            SELECT user_id
            FROM public.user_profiles
            WHERE company_id = (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can insert their own events"
    ON public.calendar_events FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own events"
    ON public.calendar_events FOR UPDATE
    USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own events"
    ON public.calendar_events FOR DELETE
    USING (user_id = auth.uid());

-- Grant permissions
GRANT ALL ON public.calendar_events TO authenticated;

-- Insert some sample events for testing
INSERT INTO public.calendar_events (user_id, title, description, type, start_date, start_time, end_date, end_time, location) VALUES
    (
        (SELECT id FROM auth.users LIMIT 1),
        'Team Meeting',
        'Weekly team sync and planning session',
        'meeting',
        CURRENT_DATE + INTERVAL '1 day',
        '10:00:00',
        CURRENT_DATE + INTERVAL '1 day',
        '11:00:00',
        'Conference Room A'
    ),
    (
        (SELECT id FROM auth.users LIMIT 1),
        'Client Consultation',
        'On-site consultation with Acme Corp',
        'on-site-consultation',
        CURRENT_DATE + INTERVAL '3 days',
        '14:00:00',
        CURRENT_DATE + INTERVAL '3 days',
        '16:00:00',
        'Acme Corp Office'
    ),
    (
        (SELECT id FROM auth.users LIMIT 1),
        'Training Session',
        'New software training for team',
        'training',
        CURRENT_DATE + INTERVAL '5 days',
        '09:00:00',
        CURRENT_DATE + INTERVAL '5 days',
        '17:00:00',
        'Training Center'
    );