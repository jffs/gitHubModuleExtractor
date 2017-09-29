class GitHubCommitService
  def self.getCommitsData(github,usuario,repositorio)
    commits= github.repos.commits.list usuario, repositorio
    array_commits = Array.new()
    for commit in commits.body
      array_commits.push({autor:commit.commit.author.date,fecha:commit.commit.author.date,mensaje:commit.commit.message,sha: commit.sha})
    end
    return array_commits
  end

  def self.getCommitedFiles(github,userName,repoName,sha)
    singleCommit= github.repos.commits.get userName, repoName,sha

    array_commits = Array.new()

    for commit in singleCommit.body.files
      patch = GitDiffParser::Patch.new(commit.patch)
      array_commits.push({name: commit.filename,additions: commit.additions,deletions: commit.deletions, patch: patch})
    end
    return array_commits
  end
  def self.getAddedLines(files)
#Creo un hash con key-value => fileName-LinesAdded
    hash_fileline = Hash.new
# el @files es el arreglo que me devuelve "getCommitedFiles"
    for file in files
      lines = file[:patch].changed_lines
      hash_fileline[file[:name]] = lines
      #array_lines.push({fileName: file[:name],linesAdded: lines})
    end
    return hash_fileline
  end
end