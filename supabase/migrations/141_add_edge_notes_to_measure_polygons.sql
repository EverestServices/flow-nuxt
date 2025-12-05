begin;

-- [139] Add manual and manual_shapes to measure_wall_images
alter table if exists public.measure_wall_images
  add column if not exists manual boolean not null default false;

alter table if exists public.measure_wall_images
  add column if not exists manual_shapes jsonb not null default '[]'::jsonb;

-- [140] Fix RLS policies for measure_wall_images
alter table if exists public.measure_wall_images enable row level security;

drop policy if exists "allow_select_images_same_company" on public.measure_wall_images;
drop policy if exists "allow_insert_images_same_company" on public.measure_wall_images;
drop policy if exists "allow_update_images_same_company" on public.measure_wall_images;
drop policy if exists "allow_delete_images_same_company" on public.measure_wall_images;

create policy "allow_select_images_same_company" on public.measure_wall_images
for select
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_wall_images.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_insert_images_same_company" on public.measure_wall_images
for insert
to authenticated
with check (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_wall_images.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_update_images_same_company" on public.measure_wall_images
for update
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_wall_images.wall_id
      and up.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_wall_images.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_delete_images_same_company" on public.measure_wall_images
for delete
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_wall_images.wall_id
      and up.user_id = auth.uid()
  )
);

alter table if exists public.measure_polygons
  add column if not exists edge_notes_cm jsonb,
  add column if not exists edge_notes_rect jsonb,
  add column if not exists edge_notes_norm jsonb;

alter table if exists public.measure_polygons enable row level security;

drop policy if exists "allow_select_polygons_same_company" on public.measure_polygons;
drop policy if exists "allow_insert_polygons_same_company" on public.measure_polygons;
drop policy if exists "allow_update_polygons_same_company" on public.measure_polygons;
drop policy if exists "allow_delete_polygons_same_company" on public.measure_polygons;

create policy "allow_select_polygons_same_company" on public.measure_polygons
for select
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_polygons.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_insert_polygons_same_company" on public.measure_polygons
for insert
to authenticated
with check (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_polygons.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_update_polygons_same_company" on public.measure_polygons
for update
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_polygons.wall_id
      and up.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_polygons.wall_id
      and up.user_id = auth.uid()
  )
);

create policy "allow_delete_polygons_same_company" on public.measure_polygons
for delete
to authenticated
using (
  exists (
    select 1
    from public.measure_walls w
    join public.surveys s on s.id = w.survey_id
    join public.user_profiles up on up.company_id = s.company_id
    where w.id = measure_polygons.wall_id
      and up.user_id = auth.uid()
  )
);

commit;
