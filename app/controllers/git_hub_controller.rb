require "pstore"
require 'json'
require 'builder'
require 'FileUtils'
class GitHubController < ApplicationController
 skip_before_action :verify_authenticity_token
 before_action :gitSession, :except => [:auth, :sign_in]

  def auth
    #Session.setSessionId(sessionID)
    if !getCurrentGitSession.nil?
    #if !GitHubService.getCurrentGitSession.nil?
      redirect_to git_hub_repos_path
    end
  end
  def sign_in
      if params[:user].blank? or params[:password].blank?
        redirect_to git_hub_auth_path, alert: "Neither username nor password can't be blank"
      else
        @usuario=params[:user]
        @password=params[:password]
        #si no hay una sesión iniciada, la inicio
         #if GitHubService.getCurrentGitSession.nil?
         if getCurrentGitSession.nil?
           response= GitHubService.gitStart({usuario: @usuario, password: @password})
           #si hay un error
           if response[:code] == 1
             respond_to do |format|
              format.html { redirect_to git_hub_auth_path, alert: response[:message]}
             end
           else
             #si no hay error almaceno como variable de sesión el objeto GIT y el usuario
             respond_to do |format|
               setCurrentGitSession(response[:github])
               setCurrentUser (@usuario)
               format.html { redirect_to git_hub_repos_path, notice: response[:message]}
             end
           end
         else
          respond_to do |format|
            format.html { redirect_to git_hub_repos_path, notice: "Welcome!"}
          end
         end
      end
  end
  def sign_out
    #GitHubService.sign_out
    FileUtils.rm(getSessionID+"data.pstore")
    reset_session
    respond_to do |format|
      format.html { redirect_to root_path}
    end
  end
  ##
  # def commits
  #repositorio= params[:repoNombre]
  #  @commits= GitHubService.getCommitsData(repositorio)
  #end
  def repos
      @repositorios= GitHubService.getRepositorios(getCurrentUser)
  end

  ##
  # def singleCommit
  # @files = GitHubService.getCommitedFiles(params[:sha])
  # @lines = GitHubService.getAddedLines(@files)
  # end
  def repoTree
   if !params[:repoNombre].nil?
     setCurrentRepo(params[:repoNombre])
   end
   @currentRepo=getCurrentRepo
   @fileSelected=false
   if params[:sha].nil?
     begin
       @repoTree = GitHubService.getFilesfromSha(getCurrentGitSession,getCurrentUser,getCurrentRepo,'master')
     rescue => e
       redirect_to git_hub_repos_path, alert: 'This repository is empty!'
     end
   else
     if params[:type] == 'tree'
       @repoTree = GitHubService.getFilesfromSha(getCurrentGitSession,getCurrentUser,getCurrentRepo,params[:sha])
     else
       @fileName=params[:name]
       @fileSelected=true
       @fileSha=params[:sha]
       @contenido=GitHubService.getFileContent(getCurrentGitSession,getCurrentUser,getCurrentRepo, params[:sha])
       @lines=FileToExport.getLines(getSessionID,@fileSha)
     end
     render 'repoTree'
   end
  end

  def submitForm
    session_id=getSessionID
    FileToExport.addFileIntoModule(session_id ,params[:fileName],params[:fileSha],params[:entiredFile], params[:lines], params[:repoName])
    redirect_to(:back, notice: "Success")
  end

  def gitSession
    @gitSession= getCurrentGitSession
  if !@gitSession.nil?
    @currentUser=getCurrentUser
  else
    redirect_to :root, alert: 'You must be signed in to access this page'
  end
  end

  def exportFiles
    @files=FileToExport.getComponentToExport(getSessionID)
    recursive_tree= GitHubRepositorioService.getRecursiveTree(getCurrentGitSession,getCurrentUser,getCurrentRepo,'master')
    GitHubService.updateFiles(getCurrentUser,getCurrentGitSession,@files, recursive_tree)
    xml = Builder::XmlMarkup.new(:target=>$stdout, :indent=>2)
    respond_to do |format|
     format.xml { send_data render_to_string(:exportFiles), filename: 'exported_module.xml', type: 'application/xml', disposition: 'attachment' }
    end
    FileToExport.setComponentToExport(getSessionID,nil)
  end

  def filesToExport
    if FileToExport.getFilesCount(getSessionID) == 0
      redirect_to git_hub_repos_path, alert: "There's no file to export yet"
    else
      @stored_files=FileToExport.getComponentToExport(getSessionID)
    end
  end

  def deleteFile
    FileToExport.deleteFile(getSessionID,params[:sha])
    redirect_to git_hub_filesToExport_path, notice: "The file was deleted."
  end

  def setCurrentGitSession(gitObject)
   session[:git_session]=gitObject.basic_auth
    session[:id]=request.session_options[:id]
  end

  def getSessionID
   session[:id]
  end

  def getCurrentGitSession
    if session[:git_session].nil?
      return nil
    else
      Github.new basic_auth: session[:git_session]
    end
  end

  def getCurrentUser
    session[:current_user]
  end

  def setCurrentUser(user)
    session[:current_user]=user
  end

  def setCurrentRepo(repoName)
    session[:current_repo]=repoName
  end

  def getCurrentRepo
    session[:current_repo]
  end
end
