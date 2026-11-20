# Catálogo de Plantas e Orçamentos

Aplicação web interna para Vale Europeu Plantas e Rony Gigante. O frontend é hospedado no GitHub Pages; autenticação, banco de dados e fotos ficam no Supabase.

## Funcionalidades
- Login por e-mail e senha, com autorização individual de administradores.
- Catálogo compartilhado entre as duas marcas.
- Cadastro de cada apresentação comercial com nome popular, nome científico, altura, DAP, preço, disponibilidade, foto e observações.
- Upload automático da foto para Supabase Storage (JPEG, PNG ou WebP até 8 MB).
- Busca por nome popular/científico e filtro de disponibilidade.
- Edição e exclusão de apresentações.
- Montagem de orçamento com marca, cliente, contato, data, validade, observações, itens, quantidades e preço unitário editável.
- Geração de PDF com identidade tipográfica da marca, fotos, especificações, subtotais e total.
- Layout responsivo para celular e computador.

## 1. Configurar Supabase
1. Crie um projeto em https://supabase.com.
2. Abra **SQL Editor** e execute todo o conteúdo de `supabase.sql`.
3. Em **Authentication > Users**, crie o primeiro usuário com e-mail e senha. Desative o cadastro público (sign-ups) em Authentication, se não for necessário permitir autoinscrição.
4. Abra o usuário criado e copie o UUID.
5. No SQL Editor, autorize o usuário executando (com os dados reais):

   ```sql
   insert into public.app_admins (user_id, email)
   values ('UUID_DO_USUARIO', 'email@empresa.com.br');
   ```

6. Repita os passos 4 e 5 para cada pessoa que poderá administrar o catálogo.
7. Em **Project Settings > API**, copie a **Project URL** e a chave pública **anon/publishable**.

## 2. Conectar o site
No início do `index.html`, substitua:
- `COLE_A_URL_DO_SEU_PROJETO` pela Project URL.
- `COLE_A_CHAVE_ANON_PUBLIC` pela chave anon/public ou publishable do projeto.

A chave pública pode ficar no frontend porque o acesso aos dados é protegido por RLS e pela lista `app_admins`. **Nunca coloque a chave `service_role` no HTML.**

## 3. Publicar no GitHub Pages
1. Envie `index.html` para a raiz do repositório (ou para a pasta que será publicada).
2. No GitHub, abra **Settings > Pages**.
3. Em **Build and deployment**, selecione **Deploy from a branch**, branch `main` e pasta `/ (root)`.
4. Salve e aguarde o deploy.

## Segurança e observações
- O site não tem botão de criar conta. Usuários são criados pelo administrador no Supabase e precisam ser incluídos em `app_admins`.
- As fotos ficam em bucket público para que o navegador e o PDF consigam carregá-las. Isso significa que quem tiver o endereço direto de uma foto poderá visualizá-la. Não coloque imagens confidenciais nesse bucket.
- Os registros e preços da tabela `plants` não são públicos; somente usuários autorizados podem consultá-los ou alterá-los.
- O catálogo e o preço por apresentação são compartilhados entre as duas marcas nesta versão. No orçamento, o preço unitário pode ser ajustado sem alterar o cadastro original.
- O PDF usa cabeçalhos tipográficos provisórios. Para aplicar os logotipos oficiais, adicione os arquivos de logo e integre-os ao cabeçalho.
- A geração de PDF ocorre no navegador. O site não salva histórico de orçamentos no banco nesta versão.
- GitHub Pages hospeda somente o frontend estático. Supabase é necessário para login, banco e armazenamento.
