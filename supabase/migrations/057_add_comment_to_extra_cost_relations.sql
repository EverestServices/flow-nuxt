-- Add comment column to extra_cost_relations table
-- This allows storing notes/comments for each extra cost relationship

ALTER TABLE public.extra_cost_relations
ADD COLUMN comment TEXT;

COMMENT ON COLUMN public.extra_cost_relations.comment IS 'Optional comment or note for this extra cost relation';
