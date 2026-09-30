# Site de Atacado (GitHub Pages + Supabase)

## 1. Supabase
1. Crie um projeto em supabase.com.
2. **SQL Editor** → cole todo o `schema.sql` → Run.
3. **Authentication → Providers → Email** → desative **Confirm email** (para o teste).
4. **Project Settings → API** → copie a *Project URL* e a chave *anon public*.

## 2. Configurar o site
Em `index.html`, troque `COLE_AQUI_A_URL` e `COLE_AQUI_A_ANON_KEY` pelos valores copiados.

## 3. GitHub Pages
1. Crie um repositório e envie `index.html` (e os demais arquivos).
2. **Settings → Pages → Deploy from a branch → main / root**.
3. O site ficará em `https://SEU-USUARIO.github.io/SEU-REPO/`.

## 4. Criar as contas especiais (cadastre pelo próprio site)
- Admin: `admin@admin.com` / `admin123` → vira admin e já nasce aprovado.
- Produção: `producao@admin.com` / senha à sua escolha → vira produção e já nasce aprovado.
- Qualquer outro cadastro fica **pendente** até o admin aprovar na aba *Clientes*.

## Perfis
- **Admin**: produtos (foto, cor, preço, quantidade), clientes (aprovar/bloquear), pedidos, chat, logo/nome/cor da loja.
- **Produção**: altera status do pedido (Novo, Em produção, Pronto, Entregue), define horário e envia mensagens prontas por WhatsApp.
- **Cliente**: catálogo, carrinho, pedido com horário desejado, acompanhamento e chat.

> Conta admin/admin123 é só para teste. Antes de usar de verdade, troque a senha.
