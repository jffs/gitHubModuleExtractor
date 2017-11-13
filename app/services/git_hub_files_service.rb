class GitHubFilesService
  #Obtiene el contenido del archivo (blob) apartir de su SHA
  def self.getFileContent(github,userName,repoName,sha)
    blob= github.git_data.blobs.get userName, repoName, sha
    return Base64.decode64(blob.body.content)
  end
  #Obtiene los archivos/subdirectorios de un Tree a partir de su SHA
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
  #Actualiza usando la Content API de Git los archivos que han sido seleccionados
  # para la extacción de lineas, o eliminado
  def self.updateFiles(userName,contents,stored_files,recursive_tree)
    stored_files.each do |file|
      full_path=recursive_tree[file.sha]
     if file.deleted == "true"
       response=deleteFile(userName,file.repo, contents,file.sha,full_path)
     else
       file_contentData = contents.find(userName,file.repo, full_path)
       lines = Base64.decode64(file_contentData.content).lines
       #Busco las lineas del archivo original, usando el numero en las lineas del archivo guardado
         file.lines.each do |line|
          if !line[:contenido].nil?
           lines[line[:numero].to_i-1].replace("")
         end
        end
        modifiedFile = lines.join("")
        response= contents.update(userName,file.repo,full_path,
                        path: full_path,
                        content: modifiedFile ,
                        message: "Update file" ,
                        sha: file_contentData.sha)
     end
    end
  end
  def self.deleteFile(userName,repo, contents,file_sha,file_path)
    contents.delete userName, repo, file_path,
                  path: file_path,
                  message: 'Delete file',
                  sha: file_sha
  end
end