xml.instruct!
#si la linea es seleccionada, tiene el campo "contenido"
xml.module do
  @files.each do |file|
    if file.deleted == "true" || file.deleted=="on"
      xml.file(:name => file.name, :delete => 'true') do
        xml.lineas do
          linesJSON=file.lines
          for line in linesJSON
            if !line["contenido"].nil?
              xml.line { |l| l.number(line["numero"]); l.content(line["contenido"]) }
            end
          end
        end
      end
    else
      xml.file(:name => file.name) do
        xml.lineas do
          linesJSON=file.lines
          for line in linesJSON
            if !line["contenido"].nil?
              xml.line { |l| l.number(line["numero"]); l.content(line["contenido"]) }
            end
          end
        end
      end
    end
  end
end