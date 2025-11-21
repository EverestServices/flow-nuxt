begin;

-- Add bytea and metadata columns to store image files in DB
alter table if exists public.measure_wall_images
  add column if not exists original_blob bytea,
  add column if not exists original_mime text,
  add column if not exists original_name text,
  add column if not exists processed_blob bytea,
  add column if not exists processed_mime text,
  add column if not exists processed_name text;

-- Function: set original image from base64
create or replace function public.measure_set_original_image(
  p_image_id uuid,
  p_base64 text,
  p_mime text,
  p_name text
) returns void
language plpgsql
security definer
set search_path = public as $$
begin
  update public.measure_wall_images
  set original_blob = decode(p_base64, 'base64'),
      original_mime = p_mime,
      original_name = p_name,
      updated_at = now()
  where id = p_image_id;
end;
$$;

-- Function: set processed image from base64
create or replace function public.measure_set_processed_image(
  p_image_id uuid,
  p_base64 text,
  p_mime text,
  p_name text
) returns void
language plpgsql
security definer
set search_path = public as $$
begin
  update public.measure_wall_images
  set processed_blob = decode(p_base64, 'base64'),
      processed_mime = p_mime,
      processed_name = p_name,
      updated_at = now()
  where id = p_image_id;
end;
$$;

-- Function: get image as base64 (original or processed)
create or replace function public.measure_get_image(
  p_image_id uuid,
  p_kind text
) returns table(mime text, name text, content_base64 text)
language plpgsql
security definer
set search_path = public as $$
begin
  if lower(p_kind) = 'original' then
    return query
      select original_mime, original_name, encode(original_blob, 'base64')
      from public.measure_wall_images where id = p_image_id;
  else
    return query
      select processed_mime, processed_name, encode(processed_blob, 'base64')
      from public.measure_wall_images where id = p_image_id;
  end if;
end;
$$;

grant execute on function public.measure_set_original_image(uuid, text, text, text) to authenticated;
grant execute on function public.measure_set_processed_image(uuid, text, text, text) to authenticated;
grant execute on function public.measure_get_image(uuid, text) to authenticated;

commit;
