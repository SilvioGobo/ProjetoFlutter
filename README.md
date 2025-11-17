🔧 Tecnologias Utilizadas

-Flutter (Material 3): Framework principal para o desenvolvimento UI.

-Firebase Authentication: Para login e cadastro de usuários.

-Cloud Firestore: Banco de dados NoSQL em tempo real para salvar os dados (veículos e abastecimentos) de forma segura.

-Provider: Para gerenciamento de estado e separação de responsabilidades.

-fl_chart: Para a criação dos gráficos de barra interativos.

-intl: Para formatação de datas (dd/MM/yyyy) e valores monetários (R$).

🏗️ Fluxo da Arquitetura

1. Camada de Serviços

Temos duas classes de serviço principais em lib/services/:

-AuthService:

Controla quem está logado (login, logout, cadastrar).

-FirestoreService:

Controla o que o usuário possui (addVeiculo, getVeiculosStream, addAbastecimento, getUltimoAbastecimento, etc.).

2. Provider no main.dart

O main.dart usa MultiProvider para "injetar" os serviços na árvore de widgets. A peça mais importante é o ProxyProvider:

Ele escuta o AuthService.

Quando o AuthService avisa que tem um usuário (ex: auth.usuario != null)...

ele automaticamente cria o FirestoreService, pegando o uid do AuthService e entregando ao FirestoreService.

Se o usuário desloga (auth.usuario == null), o ProxyProvider destrói o FirestoreService, fazendo com que não vaze dados.

3. Telas

main.dart usa Consumer<AuthService> para decidir qual tela raiz mostrar (LoginScreen ou HomeScreen).

Telas de Lista (ex: VeiculosListScreen) usam StreamBuilder conectado ao stream do FirestoreService para ouvir o banco em tempo real.

Telas de Formulário (ex: AddAbastecimentoScreen) usam context.read<FirestoreService>() para chamar as funções de salvar.

