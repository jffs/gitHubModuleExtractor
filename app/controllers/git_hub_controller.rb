require "pstore"
require 'json'
require 'builder'
class GitHubController < ApplicationController
 skip_before_action :verify_authenticity_token
 before_action :gitSession, :except => [:auth, :sign_in]

  def auth
    if !GitHubService.getCurrentGitSession.nil?
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
         if GitHubService.getCurrentGitSession.nil?
           response= GitHubService.gitStart({usuario: @usuario, password: @password})
           if response[:code] == 1
             respond_to do |format|
              format.html { redirect_to git_hub_auth_path, alert: response[:message]}
             end
           else
             respond_to do |format|
               #@repositorios= getRepositorios
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
    GitHubService.sign_out
    respond_to do |format|
      format.html { redirect_to git_hub_auth_path}
    end
  end
  def commits
    repositorio= params[:repoNombre]
    @commits= GitHubService.getCommitsData(repositorio)
  end 
  def repos

      @repositorios= GitHubService.getRepositorios
    end
  def singleCommit
    @files = GitHubService.getCommitedFiles(params[:sha])
    @lines = GitHubService.getAddedLines(@files)
  end
  def submitForm

    FileToExport.addFileIntoModule(params[:fileName],params[:fileSha],params[:entiredFile], params[:lines])
    @files=FileToExport.getComponentToExport
    #xml = Builder::XmlMarkup.new(:target=>$stdout, :indent=>2)
    #respond_to do |format|
     #format.html # index.html.erb
    #format.xml { send_data render_to_string(:submitForm), filename: 'module.xml', type: 'application/xml', disposition: 'attachment' }
    #end
  end
  def repoTree
    if !params[:repoNombre].nil?
      GitHubRepositorioService.setCurrentRepo(params[:repoNombre])
    end
    @currentRepo=GitHubRepositorioService.getCurrentRepo;
    @fileSelected=false
    if params[:sha].nil?
      @repoTree = GitHubService.getFilesfromSha('master')
    else
      if params[:type] == 'tree'
        @repoTree = GitHubService.getFilesfromSha(params[:sha])
      else
        @fileName=params[:name]
        @fileSelected=true
        @fileSha=params[:sha]
        @contenido=GitHubService.getFileContent(params[:sha])

      end
      render 'repoTree'
    end
  end
def gitSession
  @gitSession= GitHubService.getCurrentGitSession
  if !@gitSession.nil?
    @currentUser=GitHubService.getCurrentUser
  else
    redirect_to git_hub_auth_path, alert: 'You must be signed in to access this page'
  end
end
  def exportFiles
    recursive_tree= GitHubRepositorioService.getRecursiveTree('master')
    filesToExport= FileToExport.getComponentToExport
    GitHubService.updateFiles(filesToExport, recursive_tree)
    redirect_to git_hub_repos_path
  end
end
