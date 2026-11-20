-- Execute este script no SQL Editor do Supabase.
create extension if not exists pgcrypto;

create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  scientific_name text,
  height text not null,
  dap text not null,
  price numeric(12,2) not null default 0,
  availability text not null default 'Disponível',
  photo_url text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.plants enable row level security;

-- Usuários autenticados podem administrar o catálogo.
create policy "Authenticated users can read plants"
on public.plants for select to authenticated using (true);

create policy "Authenticated users can insert plants"
on public.plants for insert to authenticated with check (true);

create policy "Authenticated users can update plants"
on public.plants for update to authenticated using (true) with check (true);

create policy "Authenticated users can delete plants"
on public.plants for delete to authenticated using (true);

-- Bucket público para que as fotos apareçam nos PDFs e no catálogo.
insert into storage.buckets (id, name, public)
values ('plant-photos', 'plant-photos', true)
on conflict (id) do update set public = true;

create policy "Authenticated users can upload plant photos"
on storage.objects for insert to authenticated
with check (bucket_id = 'plant-photos');

create policy "Public can view plant photos"
on storage.objects for select to public
using (bucket_id = 'plant-photos');

create policy "Authenticated users can update plant photos"
on storage.objects for update to authenticated
using (bucket_id = 'plant-photos') with check (bucket_id = 'plant-photos');

create policy "Authenticated users can delete plant photos"
on storage.objects for delete to authenticated
using (bucket_id = 'plant-photos');
