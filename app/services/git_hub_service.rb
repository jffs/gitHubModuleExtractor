require "pstore"
require "json"
require "net/http"
class GitHubService
## Getters y setters de la sesión actual
  ##
# def self.setCurrentGitSession(gitHubObject)
    #session[:git_session] = gitHubObject
    #session[:current_user] = gitHubObject.login
    # store = storeInstance
  #   store.transaction do
  #     store[:github_session] = gitHubObject
  #     store[:current_user] = gitHubObject.login
  #  end
  # end

 ##
# def self.getCurrentGitSession
    #obtengo la sesión, si la hay de git
    #store = storeInstance
    #@github = store.transaction { store.fetch(:github_session, nil) }
    #return @github
    #return session[:git_session]
  #end

  #def self.getCurrentUser
    #store = storeInstance
    #user = store.transaction { store.fetch(:current_user, nil) }
    #return user
    #return session[current_user]
  #end

  # Método para instanciar un objeto git a partir de las credenciales de acceso
  def self.gitStart(params)
      if checkCredentials(params[:usuario],params[:password])
        github = Github.new basic_auth: params[:usuario]+':'+params[:password]
        #setCurrentGitSession(github)
        msg = { :code => 0, :message => "Welcome! you have signed up successfully.", :github => github}
      else
        msg = { :code => 1, :message => "Username or password is incorrect"}
      end
      return msg
  end

  #def self.sign_out
    #reset_session
    #store = storeInstance
    #store.transaction do
     # store.roots.each do |root|
      #  store.delete(root)
      #end
    #end
  #end
## Interacción con los archivos
# Método que devuelve el contenido de un archivo, apartir de su "sha"
  def self.getFileContent(git_session,current_user,current_repo,file_sha)
    return GitHubFilesService.getFileContent(git_session,
                                             current_user,
                                             current_repo,
                                             file_sha)
  end

# Método que devuelve los archivos de un "tree" a partir del "sha" del padre
  def self.getFilesfromSha(git_session,current_user,current_repo,tree_sha)
      GitHubFilesService.getFilesfromSha(git_session,
                                         current_user,
                                         current_repo,
                                              tree_sha)

  end

## Interacción con los Repositorios
  def self.getRepositorios(current_user)
    return GitHubRepositorioService.getRepositorios(current_user)
  end
## Interacción con los Commits
# Devuelve los commits de un repositorio
 ## def self.getCommitsData(repositorioNombre)
   # GitHubRepositorioService.setCurrentRepo(repositorioNombre)
    #return GitHubCommitService.getCommitsData(getCurrentGitSession,getCurrentUser,repositorioNombre)
  #end

# Devuelve los archivos del commit, a partir de su "sha"
  #def self.getCommitedFiles(commitSha)
   # return GitHubCommitService.getCommitedFiles(getCurrentGitSession,
    #                                            getCurrentUser,
    #                                            GitHubRepositorioService.getCurrentRepo,
   #                                             commitSha)
  #end

# Devuelve las lineas agregadas de un archivo

##
  #  def self.getAddedLines(files)
    #return GitHubCommitService.getAddedLines(files)
  #end
  def self.getGitContent
    return Github::Client::Repos::Contents.new(login: @current_user, password: @git_session.password)
  end
  def self.updateFiles(current_user,git_session,storeFiles,tree)
    @current_user=current_user
    @git_session=git_session
    GitHubFilesService.updateFiles(current_user,self.getGitContent,storeFiles,tree)
  end
#Checkea que las credenciales sean validas 
  def self.checkCredentials(username,password)
    uri = URI.parse("https://api.github.com")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(username, password)

    req_options = {
        use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return response.code == "200"
# response.code
# response.body
  end
 ## def self.storeInstance
    #return PStore.new(sessionId+"data.pstore")
   # return PStore.new("data.pstore")
  #end
end