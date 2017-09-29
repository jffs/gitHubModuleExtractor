require "pstore"
require "json"
class GitHubService
## Getters y setters de la sesión actual
  def self.setCurrentGitSession(gitHubObject)
    store = PStore.new("data.pstore")
      store.transaction do
        store[:github_session] = gitHubObject
        store[:current_user] = gitHubObject.login
      end
  end

  def self.getCurrentGitSession
    #obtengo la sesión, si la hay de git
    store = PStore.new("data.pstore")
    @github = store.transaction { store.fetch(:github_session, nil) }
    return @github
  end

  def self.getCurrentUser
    store = PStore.new("data.pstore")
    user = store.transaction { store.fetch(:current_user, nil) }
    return user
  end

  # Método para instanciar un objeto git a partir de las credenciales de acceso
  def self.gitStart(params)
    begin
      github = Github.new basic_auth: params[:usuario]+':'+params[:password]
    rescue Github::Error::Unauthorized => e
      msg= {code: 1, error: "Inicio de sesion erroneo"}
        return msg
    rescue Github::Error::GithubError => e
      msg= {code: 1, error: "Error"}
        return msg
    else
      setCurrentGitSession(github)
      msg = { :code => 0, :message => "Success!" }
      return msg
    end
  end

  def self.sign_out
    store = PStore.new("data.pstore")
    store.transaction do
      store.roots.each do |root|
        store.delete(root)
      end
    end
  end
## Interacción con los archivos
# Método que devuelve el contenido de un archivo, apartir de su "sha"
  def self.getFileContent(fileSha)
    return GitHubFilesService.getFileContent(getCurrentGitSession,
                                             getCurrentUser,
                                             GitHubRepositorioService.getCurrentRepo,
                                             fileSha)
  end

# Método que devuelve los archivos de un "tree" a partir del "sha" del padre
  def self.getFilesfromSha(treeSha)
    return GitHubFilesService.getFilesfromSha(getCurrentGitSession,
                                              getCurrentUser,
                                              GitHubRepositorioService.getCurrentRepo,
                                              treeSha)

  end

## Interacción con los Repositorios
  def self.getRepositorios
    return GitHubRepositorioService.getRepositorios(getCurrentUser)
  end
## Interacción con los Commits
# Devuelve los commits de un repositorio
  def self.getCommitsData(repositorioNombre)
    GitHubRepositorioService.setCurrentRepo(repositorioNombre)
    return GitHubCommitService.getCommitsData(getCurrentGitSession,getCurrentUser,repositorioNombre)
  end

# Devuelve los archivos del commit, a partir de su "sha"
  def self.getCommitedFiles(commitSha)
    return GitHubCommitService.getCommitedFiles(getCurrentGitSession,
                                                getCurrentUser,
                                                GitHubRepositorioService.getCurrentRepo,
                                                commitSha)
  end

# Devuelve las lineas agregadas de un archivo

  def self.getAddedLines(files)
    return GitHubCommitService.getAddedLines(files)
  end
end