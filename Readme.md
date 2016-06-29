# TVMazeAPI

Caminhos ultilizados:
  Launchscreen:
    Mesma imagem do ícone.
  
  Home:
    *UISegmentedControl*
      Para visualização de 'Todas' as Séries ou as 'Favoritas';
    *UITableView*
      Para visualização das Séries, com a imagem em miniatura, nome em Verde para 'Todas' e amarelo para 'Favoritas' e o trecho inicial da sinopse;
      Quando não há uma série nos favoritos, a aba Favoritas fica apagada.
    *Swype na TableViewCell*
      Para favoritar/desfavoritar uma série.
      
  ShowDetail:
    *UIBarButton*
      Botão para favoritar/desfavoritar uma série;
    *UIImageView*
      Mesma imagem da miniatura, então ele não precisa baixar a imagem novamente, com uma borda verde seguindo o padrão do layout;
    *UITextView*
      Sinopse completa, com scroll;
    *UILabels*
      Label com os gêneros, de ponta a ponta com a possibilidade de diminuir a fonte quando passa do tamanho da tela;
      Label com a programação, seguindo o padrão americano (@ - at);
    *UISegmentedControl*
      Lista com todas as temporadas da série;
    *UITableView*
      Lista com todos os episódios da temporada selecionada. Com o número do episódio, título e data que foi ao ar.
  
  EpisodeDetail:
    *UIImageView*
      Imagem do episódio;
    *UILabel + UIVisualEffectView*
      Númeração do episódio, seguindo o padrão americano (S01E01) mais o nome do episódio;
    *UITextView*
      Sinopse do episódio.
      
  Obs:
    Todas as séries são salvas no CoreData conforme vai ocorrendo a paginação, porém quando feito uma pesquisa, as novas séries não são salvas, somente se salvas como 'Favoritas'.
    Feito paginação conforme o usuário vai descendo a TableView.
    Pesquisa é feita inicialmente localmente, mas também é feito na API, e adicionando nos termos de busca conforme vão chegando os resultados.
    Tabela de todas as séries é ordenada pelo ID retornado da API, os 'Favoritos' são por ordem alfabética.
    Por algum motivo, enquanto acontece o scroll, as imagens ficam 'presas' com imagens de outras séries, mas quando para em algum lugar, ele se atualiza.

Pods ultilizados:
Alamofire:
  -> Conexão com a API.
AlamofireImage
  -> Ultilizado para download assíncrono das imagens.
