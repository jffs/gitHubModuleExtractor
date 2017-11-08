class FileToExport
  def initialize(name,sha, isDeleted, lines)
    @name = name
    if !isDeleted.nil? && isDeleted == "on"
      @deleted= "true"
    else
      @deleted= "false"
    end
    @lines=lines
    @sha=sha
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
  def self.addFileIntoModule(name, sha, deleted,lines)
    array_content=Array.new();
    aux_array= getComponentToExport;
    if !aux_array.nil?
      array_content= aux_array;
    end
    addedFile= FileToExport.new(name, sha,deleted, lines)
    array_content.push(addedFile)
    setComponentToExport(array_content)
  end
  def self.getFilesCount
    if !getComponentToExport.nil?
      return FileToExport.getComponentToExport.length
    else
      return 0
    end

  end
end