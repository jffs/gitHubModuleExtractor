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
  def self.setComponentToExport(session_id,object)
    store = PStore.new(session_id+"data.pstore")
    store.transaction do
      store[:files_to_export] = object
    end
  end
  def self.getComponentToExport(session_id)
    store = PStore.new(session_id+"data.pstore")
    content = store.transaction { store.fetch(:files_to_export, nil) }
    return content
  end
  #Agrega un nuevo componente al arreglo de componentes
  def self.addFileIntoModule(session_id, name, sha, deleted, lines, repo)
    array_content=Array.new();
    aux_array= getComponentToExport(session_id);
    #Si ya hay elementos para exportar
    if !aux_array.nil?
      array_content= aux_array;
    end
    #Si el archivo no esta en el arreglo, lo agrego. Caso contrario, modifico el existente
    index=getFileIndex(session_id, sha)
    if index.nil?
      addedFile= FileToExport.new(name, sha,deleted, lines, repo)
      array_content.push(addedFile)
    else
      array_content[index].set_lines(lines)
      array_content[index].set_deleted(deleted)
    end
    setComponentToExport(session_id, array_content)
  end
  def self.deleteFiles(session_id,array_sha)
    array_sha.each do sha
      deleteFile(session_id,sha)
    end
  end
  def self.deleteFile(session_id,sha)
   index=getFileIndex(session_id,sha)
   aux=getComponentToExport(session_id)
   aux.delete_at(index)
   if aux.length > 0
     setComponentToExport(session_id,aux)
   else
     setComponentToExport(session_id,nil)
   end
  end
  def self.getFileIndex(session_id,sha)
    if !getComponentToExport(session_id).nil?
      getComponentToExport(session_id).find_index{|f| f.sha == sha}
    else
      return nil
    end
  end
  #metodo para borrar un componente?
  #metodo para editar un componente?
  def self.getFilesCount(session_id)
    if !getComponentToExport(session_id).nil?
      return FileToExport.getComponentToExport(session_id).length
    else
      return 0
    end

  end
  def self.getLines(session_id,file_sha)
    index= getFileIndex(session_id,file_sha)
    if index.nil?
      return []
    else
      getComponentToExport(session_id)[index].lines
    end
  end
end