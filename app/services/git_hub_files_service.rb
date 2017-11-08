class GitHubFilesService
  def self.getFileContent(github,userName,repoName,sha)
    blob= github.git_data.blobs.get userName, repoName, sha
    return Base64.decode64(blob.body.content)
  end
  
  def self.getFilesfromSha(github,userName,repoName,sha)
    array_files= Array.new()
    github.git_data.trees.get userName, repoName, sha do |file|
      if file.type == 'blob'
        array_files.push({:text => file.path, :type => file.type, :sha => file.sha})
      else
        if file.type == 'tree'
          array_files.push({:text => file.path, :type => file.type, :sha => file.sha, :node => []})
        end
      end
    end
    return array_files
  end
  def self.updateFiles(contents,stored_files,recursive_tree)

    stored_files.each do |file|
      full_path=recursive_tree[file.sha]
      file_contentData = contents.find(GitHubService.getCurrentUser,GitHubRepositorioService.getCurrentRepo, full_path)

      lines = Base64.decode64(file_contentData.content).lines
      #Busco las lineas del archivo original, usando el numero en las lineas del archivo guardado
      file.lines.each do |line|
        if !line[:contenido].nil?
          lines[line[:numero].to_i-1].replace("")
        end
      end
      modifiedFile = lines.join("")
      contents.update(GitHubService.getCurrentUser,GitHubRepositorioService.getCurrentRepo,file_contentData.name, path: full_path, content: modifiedFile , message: "commit" , sha: file_contentData.sha)
    end
  end
end