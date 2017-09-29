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
end