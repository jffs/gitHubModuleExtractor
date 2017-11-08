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
  def self.getRecursiveTree(sha)
    tree ={}
    github=GitHubService.getCurrentGitSession
    github.git_data.trees.get GitHubService.getCurrentUser, self.getCurrentRepo, sha, recursive: true do |file|
      tree[file.sha]=file.path
    end
    return tree
  end
end