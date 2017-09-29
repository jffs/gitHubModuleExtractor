class GitHubRepositorioService
  def self.getRepositorios(usuario)
    repos= Github.repos.list user: usuario
    array_repos= Array.new()
    for repositorio in repos.body
      array_repos.push({nombre: repositorio.name})
    end
    return array_repos
  end
  def self.setCurrentRepo(repo)
    store = PStore.new("data.pstore")
    store.transaction do
      store[:current_repoName] = repo
    end
  end
  def self.getCurrentRepo
    store = PStore.new("data.pstore")
    @repo = store.transaction { store.fetch(:current_repoName, nil) }
    return @repo
  end
end