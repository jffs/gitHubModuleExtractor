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
      format.html { redirect_to root_path}
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
    FileToExport.addFileIntoModule(params[:fileName],params[:fileSha],params[:entiredFile], params[:lines], params[:repoName])
    redirect_to(:back, notice: "Success")
  end
  def repoTree
    if !params[:repoNombre].nil?
      GitHubRepositorioService.setCurrentRepo(params[:repoNombre])
    end
    @currentRepo=GitHubRepositorioService.getCurrentRepo;
    @fileSelected=false
    if params[:sha].nil?
      begin
        @repoTree = GitHubService.getFilesfromSha('master')
      rescue => e
        redirect_to git_hub_repos_path, alert: 'This repository is empty!'
      end
    else
      if params[:type] == 'tree'
        @repoTree = GitHubService.getFilesfromSha(params[:sha])
      else
        @fileName=params[:name]
        @fileSelected=true
        @fileSha=params[:sha]
        @contenido=GitHubService.getFileContent(params[:sha])
        @lines=FileToExport.getLines(@fileSha)
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
    @files=FileToExport.getComponentToExport
    recursive_tree= GitHubRepositorioService.getRecursiveTree('master')
    GitHubService.updateFiles(@files, recursive_tree)
    xml = Builder::XmlMarkup.new(:target=>$stdout, :indent=>2)
    respond_to do |format|
     format.xml { send_data render_to_string(:exportFiles), filename: 'exported_module.xml', type: 'application/xml', disposition: 'attachment' }
    end
    FileToExport.setComponentToExport(nil)
  end
  def filesToExport
    if FileToExport.getFilesCount == 0
      redirect_to git_hub_repos_path, alert: "There's no file to export yet"
    else
      @stored_files=FileToExport.getComponentToExport
    end
  end
  def deleteFile
    FileToExport.deleteFile(params[:sha])
    redirect_to git_hub_filesToExport_path, notice: "The file was deleted."
  end
end
