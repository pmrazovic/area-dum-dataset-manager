namespace :section_utils do
  desc "Reads OpenData XML file and updates section coordinates"
  task update_coordinates: :environment do
  	doc = Nokogiri::XML(File.open(File.join(Rails.root, "db", "seed_data", "sections_opendata.xml")))
  	section_items = doc.xpath("//search/queryresponse/list/list_items/row/item")

  	section_items.each do |section_item|
	  	section_name = section_item.at("name").content
	  	section_short_street = section_name.split(" * ")[1].split(",")[0]
	  	section_short_street.gsub!('·','.') # replacing special catalan char
	  	section_street_type = section_name.split(" * ")[1].split(" ")[0]
	  	section_street_number = section_name.split(" * ")[1].split(", ")[1]

	  	if section_street_type == 'C'
	  		db_street = Street.where(:short_name => section_short_street.split(" ")[1..-1].join(" "), :street_type => section_street_type).first
	  	else
	  		db_street = Street.where(:short_name => section_short_street, :street_type => section_street_type).first
	  	end

	  	if db_street.nil?
	  		section_short_street = "Pont Treball Digne" if section_short_street == "C Pont del Treball Digne"  
	  		section_short_street = "Ptge Olivé" if section_short_street == "Ptge Olivé i Maristany"
	  		section_short_street = "Rda Litoral(Besòs)" if section_short_street == "Rda Litoral (Besòs)"
	  		section_short_street = "S Antoni M Claret" if section_short_street == "C Sant Antoni Maria Claret"
	  		section_short_street = "Navas de Tolosa" if section_short_street == "C Las Navas de Tolosa"
	  		section_short_street = "Pl Congrés Eucarís" if section_short_street == "Pl Congrés Eucarístic"
	  		section_short_street = "Torroella Montgrí" if section_short_street == "C Torroella de Montgrí"
	  		section_short_street = "Sagrera" if section_short_street == "C Gran de la Sagrera"
	  		section_short_street = "Ctsa Pardo Bazán" if section_short_street == "C Comtessa de Pardo Bazán"
	  		section_short_street = "Card Tedeschini" if section_short_street == "C Cardenal Tedeschini"
	  		section_short_street = "Rbla Onze Setembre" if section_short_street == "Rbla Onze de Setembre"
	  		section_short_street = "Gv Corts Catalanes" if section_short_street == "G.V. Corts Catalanes"
	  		section_short_street = "Ruíz de Padrón" if section_short_street == "C Ruiz de Padrón"
	  		section_short_street = "Trens Maquinista" if section_short_street == "C Trens de La Maquinista"
	  		section_short_street = "Turó Trinitat" if section_short_street == "C Turó de la Trinitat"
	  		section_short_street = "Pare Pérez Pulgar" if section_short_street == "C Pare Pérez del Pulgar"
	  		section_short_street = "Mare Déu Lorda" if section_short_street == "C Mare de Déu de Lorda"
	  		section_short_street = "Av Rasos Peguera" if section_short_street == "Av Rasos de Peguera"
	  		section_short_street = "S Francesc Xavier" if section_short_street == "C Sant Francesc Xavier"
	  		section_short_street = "Font Canyelles" if section_short_street == "C Font de Canyelles"
	  		section_short_street = "Pla Fornells" if section_short_street == "C Pla de Fornells"
	  		section_short_street = "Rda Dalt(Llobregat" if section_short_street == "Rda Dalt (Llobregat)"
	  		section_short_street = "Pl M Casablancas" if section_short_street == "Pl M Casablancas i Joanico"
	  		section_short_street = "Gran Sant Andreu" if section_short_street == "C Gran de Sant Andreu"
	  		section_short_street = "Pl Jardins Alfàbia" if section_short_street == "Pl Jardins d'Alfàbia"
	  		section_short_street = "Calderón Barca" if section_short_street == "C Calderón de la Barca"
	  		section_short_street = "Av M Déu Montserra" if section_short_street == "Av Mare de Déu de Montserrat"
	  		section_short_street = "J Millán González" if section_short_street == "C José Millán González"
	  		section_short_street = "Alcalde Móstoles" if section_short_street == "C Alcalde de Móstoles"
	  		section_short_street = "Mtre Serradesanfer" if section_short_street == "C Mestre Serradesanferm"
	  		section_short_street = "Av Mrq Castellbell" if section_short_street == "Av Marquès de Castellbell"
	  		section_short_street = "Domènech Montaner" if section_short_street == "C Domènech i Montaner"
	  		section_short_street = "Av Repúb Argentina" if section_short_street == "Av República Argentina"
	  		section_short_street = "Torrent Vidalet" if section_short_street == "C Torrent d'en Vidalet"
	  		section_short_street = "Torrent Flors" if section_short_street == "C Torrent de les Flors"
	  		section_short_street = "Ca l'Alegre Dalt" if section_short_street == "C Ca l'Alegre de Dalt"
	  		section_short_street = "Mare Déu Coll" if section_short_street == "C Mare de Déu del Coll"
	  		section_short_street = "F Pérez-Cabrero" if section_short_street == "C Francesc Pérez-Cabrero"
	  		section_short_street = "Comte Salvatierra" if section_short_street == "C Comte de Salvatierra"
	  		section_short_street = "S Gervasi Cassoles" if section_short_street == "C Sant Gervasi de Cassoles"
	  		section_short_street = "Pl J Folguera" if section_short_street == "Pl Joaquim Folguera"
	  		section_short_street = "Santa Fe Nou Mèxic" if section_short_street == "C Santa Fe de Nou Mèxic"
	  		section_short_street = "Pl S Gr Taumaturg" if section_short_street == "Pl Sant Gregori Taumaturg"
	  		section_short_street = "J Sebastian Bach" if section_short_street == "C Johann Sebastian Bach"
	  		section_short_street = "Comtes Bell-lloc" if section_short_street == "C Comtes de Bell-lloc"
	  		section_short_street = "Lluís Solé Sabarís" if section_short_street == "C Lluís Solé i Sabarís"
	  		section_short_street = "Av A Bastardas" if section_short_street == "Av Albert Bastardas"
	  		section_short_street = "Marquès Sentmenat" if section_short_street == "C Marquès de Sentmenat"
	  		section_short_street = "Av J Tarradellas" if section_short_street == "Av Josep Tarradellas"
	  		section_short_street = "Inst Frenopàtic" if section_short_street == "C Institut Frenopàtic"
	  		section_short_street = "Card Vives Tutó" if section_short_street == "C Cardenal Vives i Tutó"
	  		section_short_street = "Sor Eulàlia Anzizu" if section_short_street == "C Sor Eulàlia d'Anzizu"
	  		section_short_street = "Marquès Mulhacén" if section_short_street == "C Marquès de Mulhacén"
	  		section_short_street = "Av S Ramon Nonat" if section_short_street == "Av Sant Ramon Nonat"
	  		section_short_street = "Vint-i-Sis Gener" if section_short_street == "C Vint-i-sis de gener de 1641"
	  		section_short_street = "S Pere d'Abanto" if section_short_street == "C Sant Pere d'Abanto"
	  		section_short_street = "Gv Corts Catalanes" if section_short_street == "G.V. Corts Catalanes"
	  		section_short_street = "Mare Déu Port" if section_short_street == "C Mare de Déu de Port"
	  		section_short_street = "Ferrocarrils Cat" if section_short_street == "C Ferrocarrils Catalans"
	  		#section_short_street =  if section_short_street == "C Cal Cisó"
	  		section_short_street = "Mrq Campo Sagrado" if section_short_street == "C Marquès de Campo Sagrado"
	  		section_short_street = "Pl Dr Letamendi" if section_short_street == "Pl Doctor Letamendi"
	  		section_short_street = "Pg Joan Borbó" if section_short_street == "Pg Joan Borbó Comte Barcelona"
	  		section_short_street = "Dr Giné Partagàs" if section_short_street == "C Doctor Giné i Partagàs"
	  		section_short_street = "Pg Marítim Barcelo" if section_short_street == "Pg Marítim de la Barceloneta"
	  		#section_short_street =  if section_short_street == "C Sense Nom (Encants)"
	  		section_short_street = "Av Mrq Argentera" if section_short_street == "Av Marquès de l'Argentera"
	  		section_short_street = "Pg Salvat Papassei" if section_short_street == "Pg Salvat Papasseit"
	  		section_short_street = "Pl Duc Medinaceli" if section_short_street == "Pl Duc de Medinaceli"

	  		db_street = Street.where(:short_name => section_short_street).first
	  	end

			if db_street.nil?
				puts "---------- Unknown street"
				puts section_short_street
			else
				db_section = Section.where(:street_id => db_street.id, :street_no => section_street_number.to_i).first
				if db_section.nil?
					puts "---------- Unknown section for street and number"
					puts section_short_street
					puts section_street_number
				else
					lat = section_item.at("gmapx").content.to_f
					lon = section_item.at("gmapy").content.to_f

					db_section.latitude = lat
					db_section.longitude = lon
					db_section.save
				end
			end
  	end

  end
end
