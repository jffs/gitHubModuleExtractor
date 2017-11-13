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
  def set_deleted(deleted)
    @deleted=deleted
  end
  def lines
    return @lines
  end
  def set_lines(lines)
    @lines=lines
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
    #Si ya hay elementos para exportar
    if !aux_array.nil?
      array_content= aux_array;
    end
    #Si el archivo no esta en el arreglo, lo agrego. Caso contrario, modifico el existente
    index=getFileIndex(sha)
    if index.nil?
      addedFile= FileToExport.new(name, sha,deleted, lines, repo)
      array_content.push(addedFile)
    else
      array_content[index].set_lines(lines)
      array_content[index].set_deleted(deleted)
    end
    setComponentToExport(array_content)
  end
  def self.deleteFiles(array_sha)
    array_sha.each do sha
      deleteFile(sha)
    end
  end
  def self.deleteFile(sha)
   index=getFileIndex(sha)
   aux=getComponentToExport
   aux.delete_at(index)
   if aux.length > 0
     setComponentToExport(aux)
   else
     setComponentToExport(nil)
   end
  end
  def self.getFileIndex(sha)
    if !getComponentToExport.nil?
      getComponentToExport.find_index{|f| f.sha == sha}
    else
      return nil
    end
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
  def self.getLines(file_sha)
    index= getFileIndex(file_sha)
    if index.nil?
      return []
    else
      getComponentToExport[index].lines
    end
  end
end