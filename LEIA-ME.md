# Alpha Leads

Painel interno para organizar a prospeção da Alpha Tech Solutions.
**Não publique esta pasta no site**: os dados dos leads são privados.

## Como abrir
Abra o ficheiro `index.html` no navegador (duplo clique). Não precisa de instalar nada.
Use sempre o mesmo navegador: os dados ficam guardados nele.

## Como usar (ciclo diário)
1. **Importar**: junte leads de fontes públicas num CSV (modelo disponível no separador "Importar").
2. **Hoje**: veja a lista por prioridade, edite a mensagem e carregue em "Enviar no WhatsApp".
   A conversa abre com o texto pronto; você carrega em enviar. O lead passa a "Contactado".
3. **Follow-up**: ao fim de 5 dias aparece sozinho em "Hoje" (máximo 2 follow-ups).
4. **Respondeu / Não contactar**: marque cada resposta. Quem pedir para sair vai para a lista
   "Não contactar" e nunca mais aparece.
5. **Cópia de segurança**: em "Definições", exporte o JSON de vez em quando.

## Pontuação
Sem site +3 · Site fraco +2 · Só Instagram/WhatsApp +2 · Empresa nova +2 ·
Muitas avaliações +1 · Já tem site profissional -3.
Alta: 5 ou mais · Média: 3 a 4 · Baixa: 2 ou menos.

## Boas práticas
- Envie um a um e no máximo 20 a 30 por dia (o limite é configurável).
- Identifique-se e ofereça sempre a opção de sair (já vem nas mensagens).
- Use só fontes públicas. Em Portugal, empresários em nome individual contam como pessoas
  e pedem consentimento (RGPD). No Brasil aplica-se a LGPD. Não é aconselhamento jurídico.
- Nunca automatize o envio em massa: o WhatsApp pode bloquear o seu número.

---

## Fase 2: pedidos do site entram sozinhos no painel

O formulário do site grava cada pedido (com o consentimento do visitante) numa tabela do Supabase.
O painel vai buscá-los e mostra-os no topo de "Hoje", em "Pedidos do site", com uma resposta pronta.
Estes pedidos não contam para o limite diário de mensagens.

### Configuração (uma vez)
1. **Supabase > SQL Editor > New query**: cole o conteúdo de `supabase/setup.sql` e clique em Run.
   Deve aparecer `rls_ativa = true` e `politicas = 4`.
2. **Supabase > Authentication > Users > Add user**: crie o utilizador com o seu e-mail e uma
   palavra-passe (marque "Auto Confirm User"). Só esse e-mail consegue ler os pedidos.
3. **Supabase > Project Settings > API**: copie a chave **anon / publishable** (nunca a service_role).
4. Cole essa chave em dois sítios:
   - site: ficheiro `app.js`, linha `const SUPABASE_ANON_KEY = "";`
   - painel: Definições > Ligação ao site (Supabase), com o seu e-mail e a palavra-passe. Clique em Entrar.

### Como funciona a segurança
- O site só consegue **inserir** pedidos. Não consegue ler, alterar nem apagar nada.
- Só o e-mail autorizado, com sessão iniciada, lê os pedidos.
- A base de dados exige o consentimento, limita o tamanho dos campos e trava mais de 40 pedidos em 10 minutos.
- Depois de importar, o pedido fica na base marcado como importado (serve de cópia). Para cumprir um
  pedido de apagamento, apague a linha em Supabase > Table Editor > inbound_leads e o lead no painel.
- Política de privacidade: `privacidade.html` no site. Reveja o texto e acrescente os seus dados legais
  (por exemplo NIF e morada), se aplicável. Não é aconselhamento jurídico.

---

## Acompanhamento e anti-reenvio

**Separador "Acompanhamento"**: o histórico de todas as empresas já contactadas, com 1.º contacto,
último contacto, número de mensagens, resposta (Sim / Não / Aguardando), estado e próximo passo.
Clique em "Abrir" para ver a linha do tempo completa de uma empresa (cada ação, com data e hora).
"Exportar histórico (CSV)" leva tudo, incluindo a linha do tempo.

**Estados, do início ao fim**
Novo → Contactado → Em conversa → Proposta enviada → Cliente (ganho).
Fins alternativos: **Sem resposta** (arquivado sozinho 7 dias depois do último follow-up) e **Perdido**.

**Como registar uma resposta**
Nos cartões de "Hoje" (ou em "Abrir"): "Respondeu: interessado" ou "Respondeu: sem interesse".
O WhatsApp não avisa o painel, por isso esta marcação é manual.

**Regras que o painel aplica sozinho (não dá para as contornar sem querer)**
- Uma empresa já contactada **não recebe a 1.ª mensagem outra vez**, nem sob outro registo: o painel guarda
  um registo permanente (telefone, nome + cidade, Instagram, site) mesmo que o lead seja apagado.
- Follow-ups só nas datas certas (a cada 5 dias) e no máximo 2.
- Sem resposta: descanso de 90 dias. Respondeu "sem interesse": descanso de 180 dias.
- "Não contactar" bloqueia para sempre.
- Um lead contactado não pode voltar ao estado "Novo". Só "Reativar…", com confirmação (e um aviso
  reforçado se ainda estiver no período de descanso).
- Duplicados são recusados na importação CSV, no Radar e ao criar um lead à mão.
- "Apagar tudo" (Definições) também apaga o registo de contactos. Faça antes uma cópia de segurança.

---

## Pipeline, lembretes e autonomia

**Etapas:** Novo → Contactado → Reunião marcada → Proposta enviada → Negociação → Ganho / Perdido.
Quem responde "sim" fica em Contactado com a marca "Resposta: Sim" e o próximo passo "Marcar reunião".
"Perdido" guarda o motivo e o descanso: Sem resposta 90 dias, Sem interesse 180 dias.
Mude de etapa em Acompanhamento > Abrir (cada etapa pede os dados certos: data da reunião, valor,
semanas de trabalho, início previsto).

**Lembretes de hoje (4 regras, prazos em Definições > Lembretes e autonomia)**
1. Lead em conversa sem contacto há X dias (por defeito 3).
2. Proposta sem resposta há X dias (por defeito 7).
3. Reunião X dias antes (por defeito 1, e também hoje e as que já passaram sem resultado).
4. Follow-up necessário (data de follow-up chegada).

**Indicador de autonomia:** compara as semanas de trabalho contratado (projetos Ganhos, descontando as
semanas já passadas desde o início previsto) com os leads em contacto. Vermelho se as duas coisas estiverem
abaixo dos limites (por defeito 6 semanas e 5 leads), âmbar se só uma, verde se estiver tudo bem.
Para contar, preencha "Semanas de trabalho contratado" e "Início previsto" ao marcar um negócio como Ganho.

---

## Fontes de leads (separador "Fontes")

As plataformas (Instagram, LinkedIn, Workana, sites de emprego) não permitem recolher publicações
automaticamente, e tentar arrisca bloquear as suas contas. Por isso o painel faz o trabalho chato por si:

1. **Pesquisas prontas**: escolha o mercado (Portugal ou Brasil), o serviço e o período. O painel gera
   ligações que abrem a pesquisa já preenchida em cada site: Google (frases exatas na última semana),
   publicações públicas do LinkedIn e do Instagram via Google, o LinkedIn (com sessão), a Workana, empresas
   a contratar (LinkedIn, Indeed, Net-Empregos em PT, Google Vagas no BR) e hashtags do Instagram.
2. **Captura rápida** (botão "+ Captura rápida", sempre no topo): quando vir alguém a pedir o serviço,
   cole o link, o nome e o que pediu. O lead fica criado com o link como prova, prioridade alta (+6) e
   uma mensagem que cita o pedido ("Vi a sua publicação a pedir ajuda com…").
3. **Responder**: sem telefone, use "Abrir a publicação", responda na própria plataforma e clique em
   "Já respondi na plataforma". O histórico e o anti-reenvio ficam registados.
4. **Workana**: envie a proposta dentro da plataforma. As regras dela não permitem levar o cliente para fora.
5. **Editar as frases**: cada combinação mercado + serviço tem frases, cargos, termos e hashtags editáveis.
6. **Alertas grátis**: o botão copia as frases no formato do Google Alerts.
7. **Que fontes trazem clientes?**: tabela com leads, contactados, responderam e ganhos por fonte.

Rotina sugerida: 10 minutos por dia. Abra 4 ou 5 pesquisas, capture os 3 a 5 melhores pedidos.

---

## Documentos (separador "Documentos")

Propostas comerciais, relatórios mensais e documentos de entrega, gerados a partir de dados que preenche **uma só vez**.

**1. Dados da empresa (uma vez)**: Definições > Dados da empresa. Nome legal, NIF, morada, e-mail, telefone, site,
quem assina e o cargo, condições de pagamento e garantia por defeito, validade das propostas, moeda e IVA por
mercado (por defeito: Portugal € com IVA 23%, Brasil R$ sem impostos). Altere a moeda se quiser outra (por exemplo $).

**2. Dados do cliente (uma vez por cliente)**: no lead, Abrir > Documentos: pessoa de contacto, NIF ou CNPJ, morada,
e-mail e língua. Sem língua escolhida, usa PT-PT para Portugal e PT-BR para o Brasil.

**3. Gerar**: no lead (Documentos) ou no separador Documentos escolha o cliente e o tipo:
- **Proposta comercial**: linhas de serviço com quantidade e preço (e atalhos para os serviços habituais), IVA, prazo
  em semanas, condições de pagamento, validade e notas. Soma sozinha o subtotal, o IVA e o total.
- **Relatório mensal**: mês, resumo, indicadores, trabalho realizado, próximos passos.
- **Documento de entrega**: itens entregues, endereços, garantia, manutenção e termo de aceitação com assinaturas.
  Nunca guarda palavras-passe: o documento diz que os acessos foram entregues em separado.

**4. Saída**: pré-visualização no ecrã. "Imprimir ou guardar em PDF" (escolha "Guardar como PDF" como impressora) ou
"Descarregar HTML" (ficheiro autónomo, com a logo incluída). Os documentos ficam guardados no lead, com número
sequencial por tipo e ano (AT-PROP-2026-001, AT-REL-…, AT-ENT-…). Pode reabrir, editar (mantém o número) ou apagar
(o número não é reutilizado). Cada documento fica registado no histórico do lead.

**5. Línguas**: Português (Portugal), Português (Brasil), Español e English, com moeda e datas no formato certo.

---

## Resumo do dia (dentro do próprio painel, sem e-mail)

- Ao abrir o painel pela primeira vez em cada dia, aparece sozinho o **"Bom dia"**: pedidos novos do site,
  reuniões, propostas sem resposta, leads sem contacto, follow-ups e o indicador de autonomia, com os
  números do dia. Cada nome abre o lead. Só aparece se houver algo para ver (ou se o pipeline estiver curto).
- O separador **Hoje (4)** e o título do separador do navegador **(4) Alpha Leads** mostram sempre quantas
  coisas pedem atenção, mesmo com o painel noutro separador.
- O botão **"Resumo do dia"**, no topo, reabre o resumo quando quiser.
- Limite: só avisa quando o painel está aberto. Dica: fixe o painel como separador do navegador (clique
  direito no separador, "Afixar") e abra-o ao começar o dia.

## Painel (ecrã inicial)
- **Próxima ação**: o quadro colorido diz o que fazer agora, com botão direto.
- **Números clicáveis**: abrem em baixo a lista de empresas por trás de cada número.
- **Funil** clicável, taxas de resposta e de ganho, **autonomia** com barras, **gráfico** dos últimos 14 dias.
- **Pipeline > Quadro**: arraste os cartões para a fase seguinte (só avança; Reunião e Ganho abrem a ficha).

## Online (Render) com tudo na base de dados
1. Supabase > SQL Editor: executar `supabase/panel_state.sql` (uma vez).
2. Supabase > Authentication > Sign In / Providers > Email: desligar "Allow new users to sign up".
3. Criar um repositório GitHub **só com esta pasta** (nunca o resto dos Documentos).
4. Render > New > Static Site > escolher o repositório. Publish directory: `public`. Sem build command (ou usar o `render.yaml`).
5. Abrir o endereço do Render e entrar com o e-mail e a palavra-passe do Supabase.
Os dados vivem na tabela `panel_state` (protegida por RLS: só o seu e-mail). O navegador só guarda a sessão.
