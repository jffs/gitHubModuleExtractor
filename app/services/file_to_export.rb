class FileToExport
  def initialize(name, sha, isDeleted, lines, repo)
    @name = name
    if !isDeleted.nil? && isDeleted == "on"
      @deleted= "true"
    else
      @deleted= "false"
    end
    @lines=lines
    @sha=sha
    @repo=repo
  end
  def name
    return @name
  end
  def deleted
    return @deleted
  end
  def lines
    return @lines
  end
  def sha
    return @sha
  end
  def repo
    return @repo
  end
  def self.setComponentToExport(object)
    store = PStore.new("data.pstore")
    store.transaction do
      store[:files_to_export] = object
    end
  end
  def self.getComponentToExport
    store = PStore.new("data.pstore")
    content = store.transaction { store.fetch(:files_to_export, nil) }
    return content
  end
  #Agrega un nuevo componente al arreglo de componentes
  def self.addFileIntoModule(name, sha, deleted, lines, repo)
    array_content=Array.new();
    aux_array= getComponentToExport;
    if !aux_array.nil?
      array_content= aux_array;
    end
    addedFile= FileToExport.new(name, sha,deleted, lines, repo)
    array_content.push(addedFile)
    setComponentToExport(array_content)
  end
  def self.deleteFiles(array_sha)
    array_sha.each do sha
      deleteFile(sha)
    end
  end
  def self.deleteFile(sha)
   index=getFileIndex(sha)
   setComponentToExport(getComponentToExport.delete_at(index))
  end
  def self.getFileIndex(sha)
    getComponentToExport.find_index{|f| f.sha == sha}
  end
  #metodo para borrar un componente?
  #metodo para editar un componente?
  def self.getFilesCount
    if !getComponentToExport.nil?
      return FileToExport.getComponentToExport.length
    else
      return 0
    end

  end
end