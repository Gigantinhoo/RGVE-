-- CATÁLOGO DE PLANTAS | SUPABASE
-- Execute uma vez no SQL Editor do seu projeto Supabase.
-- Depois de criar os usuários em Authentication > Users, autorize-os na tabela app_admins.

create extension if not exists pgcrypto;

-- Cadastro de apresentações comerciais: cada tamanho/DAP/preço é uma linha.
create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  scientific_name text,
  height text not null,
  dap text not null,
  price numeric(12,2) not null default 0 check (price >= 0),
  availability text not null default 'Disponível'
    check (availability in ('Disponível', 'Sob consulta', 'Indisponível')),
  photo_url text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Lista de usuários autorizados. Não há cadastro público de administradores pelo site.
create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  created_at timestamptz not null default now()
);

alter table public.plants enable row level security;
alter table public.app_admins enable row level security;

-- Remove políticas permissivas da versão inicial, caso o SQL antigo já tenha sido executado.
drop policy if exists "Authenticated users can read plants" on public.plants;
drop policy if exists "Authenticated users can insert plants" on public.plants;
drop policy if exists "Authenticated users can update plants" on public.plants;
drop policy if exists "Authenticated users can delete plants" on public.plants;
drop policy if exists "Authenticated users can upload plant photos" on storage.objects;
drop policy if exists "Authenticated users can update plant photos" on storage.objects;
drop policy if exists "Authenticated users can delete plant photos" on storage.objects;

-- Cada usuário autenticado consegue consultar somente a própria autorização.
drop policy if exists "Admins can read own authorization" on public.app_admins;
create policy "Admins can read own authorization"
on public.app_admins for select to authenticated
using (user_id = auth.uid());

-- Somente usuários previamente incluídos em app_admins podem administrar o catálogo.
drop policy if exists "Authorized admins can read plants" on public.plants;
create policy "Authorized admins can read plants"
on public.plants for select to authenticated
using (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Authorized admins can insert plants" on public.plants;
create policy "Authorized admins can insert plants"
on public.plants for insert to authenticated
with check (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Authorized admins can update plants" on public.plants;
create policy "Authorized admins can update plants"
on public.plants for update to authenticated
using (exists (select 1 from public.app_admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Authorized admins can delete plants" on public.plants;
create policy "Authorized admins can delete plants"
on public.plants for delete to authenticated
using (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

-- Fotos públicas para que apareçam no catálogo e nos PDFs.
-- Os dados e preços da tabela continuam protegidos por autenticação/RLS.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('plant-photos', 'plant-photos', true, 8388608, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = true,
  file_size_limit = 8388608,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

-- Leitura pública apenas dos arquivos de imagem do bucket.
drop policy if exists "Public can view plant photos" on storage.objects;
create policy "Public can view plant photos"
on storage.objects for select to public
using (bucket_id = 'plant-photos');

-- Escrita e remoção somente por administradores autorizados.
drop policy if exists "Authorized admins can upload plant photos" on storage.objects;
create policy "Authorized admins can upload plant photos"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'plant-photos'
  and exists (select 1 from public.app_admins a where a.user_id = auth.uid())
);

drop policy if exists "Authorized admins can update plant photos" on storage.objects;
create policy "Authorized admins can update plant photos"
on storage.objects for update to authenticated
using (
  bucket_id = 'plant-photos'
  and exists (select 1 from public.app_admins a where a.user_id = auth.uid())
)
with check (
  bucket_id = 'plant-photos'
  and exists (select 1 from public.app_admins a where a.user_id = auth.uid())
);

drop policy if exists "Authorized admins can delete plant photos" on storage.objects;
create policy "Authorized admins can delete plant photos"
on storage.objects for delete to authenticated
using (
  bucket_id = 'plant-photos'
  and exists (select 1 from public.app_admins a where a.user_id = auth.uid())
);

-- IMPORTANTE: após criar um usuário em Authentication > Users, execute este comando
-- substituindo pelo UUID e e-mail reais do usuário. Repita para cada membro autorizado.
-- insert into public.app_admins (user_id, email)
-- values ('UUID_DO_USUARIO', 'email@empresa.com.br');
