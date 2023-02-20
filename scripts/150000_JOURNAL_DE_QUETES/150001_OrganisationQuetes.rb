module POKEMON_S
  #==============================================================================
  # ■ Systeme de gestion de quête
  #------------------------------------------------------------------------------
  #   Ce script a pour but de rajouter un systeme de gestion de quête sur votre
  # projet. Divers commandes script permettent d'intéragir avec ce systeme :
  #
  #   $scene = Scene_Quete.new  # Ouvre le livre de quete
  #   $pokemon_party.quete_demarrer(id_quete) # Démarre une quete
  #   $pokemon_party.quete_echouer(id_quete) # Fait echouer la quete
  #   $pokemon_party.quete_finir(id_quete) # Fait réussir la quete et donne les récompenses
  #   $pokemon_party.quete_parler(nom) # Permet de valider l'objectif de parler, quelque soit les quetes
  #   $pokemon_party.quete_termine?(id_quete) # Vérifie si les objectifs sont terminé # Dans commande condition
  #   $pokemon_party.quete_trouve?(id_quete) # Vérifie si la quête est trouvé # Dans commande condition
  #   $pokemon_party.quete_en_cours?(id_quete) # Vérifie si la quête est en cours # Dans commande condition
  #   $pokemon_party.quete_reussie?(id_quete) # Vérifie si la quête est réussi # Dans commande condition
  #   $pokemon_party.quete_echoue?(id_quete) # Vérifie si la quête est échoué # Dans commande condition
  #   $pokemon_party.quete_voir_pokemon(id_monstre) # Automatique
  #   $pokemon_party.quete_vaincre_pokemon(id_monstre) # Automatique
  #   $pokemon_party.quete_capturer_pokemon(id_monstre) # Automatique
  #   $pokemon_party.quete_objectif_termine?(id_quete,id_objectif) # Vérifie si l'objectif de la quete est terminé # Dans commande condition
  #
  #
  # Date : 20/07/2006
  #   Version   Date          Auteur        Commentaires
  #   1.00      20/09/2007    Tonyryu       Finalisation version 1
  #   1.01      23/09/2007    Tonyryu       Correction d'un bug de comparaison
  #   1.02      26/09/2007    Tonyryu       Correction Anomalie : caractere '\n' non interprété
  #   1.03      03/10/2007    Tonyryu       Correction Anomalie : quete_echouer et quete_finir buggés
  #   1.04      16/07/2008    Tonyryu       Ajout fonction quete_tuer_monstre
  #   1.05      22/07/2008    Tonyryu       Ajout fonction quete_objectif_termine? ,correction d'un bug de validation de quête, les objectifs terminés sont grisés
  #   2.00       2/01/2008    Sphinx        Adaptation à PSP4G+
  # 
  # Attention : Ce script est ma propriété en tant que création et il est donc
  # soumis au droit de la propriété intellectuelle ( http://www.irpi.ccip.fr/ ).
  # En aucun cas, il ne doit être copié ou publié vers un autre forum sans en
  # avoir reçu mon accord au préalable.
  #
  #==============================================================================
  
  #==============================================================================
  # ■ pokemon_Party
  #------------------------------------------------------------------------------
  #  Ajout de méthode de gestion de quete, permettant l'intégration à la sauvegarde
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Pokemon_Party
    
    attr_accessor :tab_quete
   
    #--------------------------------------------------------------------------
    # ● initialize (surcharge)
    #-------------------------------------------------------------------------- 
    alias quete_initialize initialize
    def initialize
      @tab_quete = {}
      maj_quetes(false)
      quete_initialize
    end
    
    #--------------------------------------------------------------------------
    # ● quete_demarrer
    #-------------------------------------------------------------------------- 
    def quete_demarrer(id_quete,jingle = true)
      # Si La quête existe
      if not $data_quete.tab_def_quete[id_quete].nil?
        # Si la quête n'est pas déjà accepter
        if @tab_quete[id_quete].nil?
          # Ajouter une entrée dans le tableau de quete du joueur
          @tab_quete[id_quete] = [1,Array.new($data_quete.tab_def_quete[id_quete]["but"].size, 0)]
        end
      else
        # Sinon, affiché un message d'erreur
        print "Quete ID : #{id_quete} non configurée!!"
      end
    end
  
    #--------------------------------------------------------------------------
    # ● quete_objectif_termine?
    #-------------------------------------------------------------------------- 
    def quete_objectif_termine?(id_quete,id_objectif)
      # Tester si la quete existe
      return false if @tab_quete[id_quete].nil?
      
      # Tester si l'ojectif existe 
      return false if $data_quete.tab_def_quete[id_quete]["but"][id_objectif].nil?
      objectif = $data_quete.tab_def_quete[id_quete]["but"][id_objectif]
      
      fait = @tab_quete[id_quete][1][id_objectif]
      sur = objectif[1]
      
      fait = ( fait > sur ? sur : fait) if objectif[0] == "TR_OBJ"
      sur = 1 if objectif[0] == "PARLER"
      return (fait == sur)
      
    end
      
    #--------------------------------------------------------------------------
    # ● quete_termine?
    #-------------------------------------------------------------------------- 
    def quete_termine?(id_quete)
     
      # Tester si la quete existe
      return false if @tab_quete[id_quete].nil?
      for i in 0...$data_quete.tab_def_quete[id_quete]["but"].size
        return false if !quete_objectif_termine?(id_quete,i)
      end
      return true
    end
    
    #--------------------------------------------------------------------------
    # ● quete_finir
    #-------------------------------------------------------------------------- 
    def quete_finir(id_quete)
      # Tester si la quete existe
      if !@tab_quete[id_quete].nil?
        # Si la quete n'est pas deja cloturer
        if @tab_quete[id_quete][0] == 1
          # changer la quete d'état
          @tab_quete[id_quete][0] = 2
          
          # Réceptionner la récompense
          for i in 0...$data_quete.tab_def_quete[id_quete]["gain"].size
            gain = $data_quete.tab_def_quete[id_quete]["gain"][i]
            nbr = gain[1]
  
            case gain[0]
            when "EXP"
              nbr /= @actors.size
              for i in 0...@actors.size
                @actors[i].exp += nbr
              end
            when "OBJ"
              $pokemon_party.add_item(gain[2], nbr)
            when "ARGENT"
              $pokemon_party.add_money(nbr)
            when "POKE"
              $pokemon_party.add(Pokemon.new(gain[1],gain[2],gain[3]))
            end
          end
        end
      end
      
    end
    
    #--------------------------------------------------------------------------
    # ● quete_echouer
    #-------------------------------------------------------------------------- 
    def quete_echouer(id_quete)
      # Si la quete est connu
      if !@tab_quete[id_quete].nil?
        # Si la quete n'est pas deja cloturer
        if @tab_quete[id_quete][0] == 1
          # changer la quete d'état
          @tab_quete[id_quete][0] = 3
        end
      end
    end
    
    #--------------------------------------------------------------------------
    # ● quete_trouve?
    #-------------------------------------------------------------------------- 
    def quete_trouve?(id_quete)
      return !@tab_quete[id_quete].nil?
    
    end
    
    #--------------------------------------------------------------------------
    # ● quete_en_cours?
    #-------------------------------------------------------------------------- 
    def quete_en_cours?(id_quete)
       return false if @tab_quete[id_quete].nil?
       
       return ( @tab_quete[id_quete][0] == 1 )
    end
    
    #--------------------------------------------------------------------------
    # ● quete_reussie?
    #-------------------------------------------------------------------------- 
    def quete_reussie?(id_quete)
       return false if @tab_quete[id_quete].nil?
       
       return (@tab_quete[id_quete][0] == 2)
     end
     
    #--------------------------------------------------------------------------
    # ● quete_echoue?
    #-------------------------------------------------------------------------- 
    def quete_echoue?(id_quete)
       return false if @tab_quete[id_quete].nil?
       
       return (@tab_quete[id_quete][0] == 3)
    end
  
    #--------------------------------------------------------------------------
    # ● maj_quetes
    #-------------------------------------------------------------------------- 
    def maj_quetes(play_jingle = true)
      jingle = false
      for i in 0...$data_quete.tab_def_quete.size
        if quete_termine?(i) and @tab_quete[i][0] == 1
          quete_finir(i)
          jingle = true
        end
      end
      for i in 0...$data_quete.tab_def_quete.size
        if $data_quete.tab_def_quete[i] == nil
          next
        end
        if $data_quete.tab_def_quete[i]["lancement"] == nil or $data_quete.tab_def_quete[i]["lancement"] == ["AUCUNE"]
          lancer = true
        else
          for j in $data_quete.tab_def_quete[i]["lancement"]
            if j.type == Fixnum and j < $data_quete.tab_def_quete.size and quete_termine?(j)
              lancer = true
            else
              lancer = false
              break
            end
          end
        end
        if lancer and @tab_quete[i].nil?
          quete_demarrer(i,false)
          jingle = true
        end
      end
      if play_jingle and jingle
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:victoire_quete]}", 100, 100)
      end
    end
  
    #--------------------------------------------------------------------------
    # ● quete_parler
    #-------------------------------------------------------------------------- 
    def quete_parler(nom)
      # Parcourir la liste des quete en cours
      @tab_quete.each_key { |id_quete|
        # Si la quete est en cours
        if @tab_quete[id_quete][0] == 1
          # Vérifier tous les objectifs de la quete
          for i in 0...$data_quete.tab_def_quete[id_quete]["but"].size
            objectif = $data_quete.tab_def_quete[id_quete]["but"][i]
            if objectif[0] == "PARLER"
              if objectif[1] == nom
                @tab_quete[id_quete][1][i] = 1
              end
            end
          end
        end
      }
     #maj_quetes
    end
    
    #--------------------------------------------------------------------------
    # ● quete_tr_obj
    #-------------------------------------------------------------------------- 
    def quete_tr_obj(id,nbr)
      # Parcourir la liste des quete en cours
      @tab_quete.each_key { |id_quete_party|
        # Si la quete est en cours
        if @tab_quete[id_quete_party][0] == 1
          # Vérifier si des objectifs sont liés à la chasse
          id_objectif = -1
          $data_quete.tab_def_quete[id_quete_party]["but"].each { |objectif|
          id_objectif += 1
            if objectif[0] == "TR_OBJ"
#              if objectif[2].type == String
#                cible = POKEMON_S::Pokemon_Info.id(objectif[2])
#              end
              if objectif[2] == id
                # ajouter 1 au compteur
                @tab_quete[id_quete_party][1][id_objectif] += nbr
                if @tab_quete[id_quete_party][1][id_objectif] > objectif[1]
                  @tab_quete[id_quete_party][1][id_objectif] == objectif[1]
                end
              end
            end
          }
        end
      }
     #maj_quetes
    end
    
    #--------------------------------------------------------------------------
    # ● quete_voir_pokemon
    #-------------------------------------------------------------------------- 
    def quete_voir_pokemon(id_monstre)
      # Parcourir la liste des quete en cours
      @tab_quete.each_key { |id_quete_party|
        # Si la quete est en cours
        if @tab_quete[id_quete_party][0] == 1
          # Vérifier si des objectifs sont liés à la chasse
          id_objectif = -1
          $data_quete.tab_def_quete[id_quete_party]["but"].each { |objectif|
          id_objectif += 1
            if objectif[0] == "VOIR"
              if objectif[2].type == String
                cible = POKEMON_S::Pokemon_Info.id(objectif[2])
              else
                cible = objectif[2]
              end
              if cible == id_monstre
                if ((objectif[3] or objectif[3] == nil) and $sauvage) or not objectif[3]
                  # ajouter 1 au compteur
                  @tab_quete[id_quete_party][1][id_objectif] += 1 if objectif[1] != @tab_quete[id_quete_party][1][id_objectif]
                end
              end
            end
          }
        end
      }
     #maj_quetes
    end
    
    #--------------------------------------------------------------------------
    # ● quete_capturer_pokemon
    #-------------------------------------------------------------------------- 
    def quete_capturer_pokemon(id_monstre)
      # Parcourir la liste des quete en cours
      @tab_quete.each_key { |id_quete_party|
        # Si la quete est en cours
        if @tab_quete[id_quete_party][0] == 1
          # Vérifier si des objectifs sont liés à la chasse
          id_objectif = -1
          $data_quete.tab_def_quete[id_quete_party]["but"].each { |objectif|
          id_objectif += 1
            if objectif[0] == "CAPTURER"
              if objectif[2].type == String
                cible = POKEMON_S::Pokemon_Info.id(objectif[2])
              else
                cible = objectif[2]
              end
              if cible == id_monstre
                if ((objectif[3] or objectif[3] == nil) and $sauvage) or not objectif[3]
                  # ajouter 1 au compteur
                  @tab_quete[id_quete_party][1][id_objectif] += 1 if objectif[1] != @tab_quete[id_quete_party][1][id_objectif]
                end
              end
            end
          }
        end
      } 
     #maj_quetes
    end
    
    #--------------------------------------------------------------------------
    # ● quete_vaincre_pokemon
    #-------------------------------------------------------------------------- 
    def quete_vaincre_pokemon(id_monstre)
      # Parcourir la liste des quete en cours
      @tab_quete.each_key { |id_quete_party|
        # Si la quete est en cours
        if @tab_quete[id_quete_party][0] == 1
          # Vérifier si des objectifs sont liés à la chasse
          id_objectif = -1
          $data_quete.tab_def_quete[id_quete_party]["but"].each { |objectif|
          id_objectif += 1
            if objectif[0] == "VAINCRE"
              if objectif[2].type == String
                cible = POKEMON_S::Pokemon_Info.id(objectif[2])
              else
                cible = objectif[2]
              end
              if cible == id_monstre
                if ((objectif[3] or objectif[3] == nil) and $sauvage) or not objectif[3]
                  # ajouter 1 au compteur
                  @tab_quete[id_quete_party][1][id_objectif] += 1 if objectif[1] != @tab_quete[id_quete_party][1][id_objectif]
                end
              end
            end
          }
        end
      } 
     #maj_quetes
    end
    
  end
end
  
  #==============================================================================
  # ■ Sprite_Battler
  #------------------------------------------------------------------------------
  #  Surcharge de la méthode update pour gestion de chasse
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Sprite_Battler
    
    #--------------------------------------------------------------------------
    # ● update (surcharge)
    #   permet de comptabiliser une créature tuée, objectif "CHASSER"
    #-------------------------------------------------------------------------- 
    alias quete_update update
    def update
      sav_battler_visible = @battler_visible
      quete_update()
      if @battler.is_a?(pokemon_Enemy) and sav_battler_visible and !@battler_visible
        # vérifier que l'id du monstre est recherché dans une quete en cours
        $pokemon_party.quete_tuer_monstre(@battler.id)
      end
     
    end
    
  end
  
  
  #==============================================================================
  # ■ Window_Optionquete
  #------------------------------------------------------------------------------
  #  Fenêtre des option de quete
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Window_Optionquete < Window_Selectable
    
    
    #--------------------------------------------------------------------------
    # ● initialize
    #-------------------------------------------------------------------------- 
    def initialize
      super(0, 0, 320, 120)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.back_opacity = 0
      self.opacity = 0
      self.contents.font.name = $fontface
      self.contents.font.size = 18
          
      self.index = 0
      @item_max =3
      @column_max = 1
      
      refresh
    end
  
    #--------------------------------------------------------------------------
    # ● refresh
    #--------------------------------------------------------------------------
    def refresh
      self.contents.clear
      # Afficher le titre
      self.contents.font.color = Color.new(100,100,100,255)
      self.contents.font.size = 24
      self.contents.draw_text(0, -2, 130, 25, "Sommaire",1)
      
      # Afficher le menu
      self.contents.font.size = 18
      self.contents.font.color = Color.new(0,0,0,255)
      self.contents.draw_text(14, 25, 200, 25, " Quêtes en cours")
      self.contents.draw_text(14, 45, 200, 25, " Quêtes réussies")
      self.contents.draw_text(14, 65, 200, 25, " Quêtes échouées")
      
      
    end
    
  
    #--------------------------------------------------------------------------
    # ● update_cursor_rect
    #    - Permet de modifier la position du rectangle de sélection à chaque cycle
    #--------------------------------------------------------------------------
    def update_cursor_rect
      # Si l'index de focus est inferieur à 0
      if @index < 0
        # Alors effacer le rectangle de sélection
        self.cursor_rect.empty
      else
        # Sinon afficher le rectangle à la position du focus
        self.cursor_rect.set(0, 26 + (20 * @index), 20, 20)
      end
    end
  end
  
  
  #==============================================================================
  # ■ Window_Listequete
  #------------------------------------------------------------------------------
  #  Fenêtre de la liste des quetes
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Window_Listequete < Window_Selectable
    
    
    #--------------------------------------------------------------------------
    # ● initialize
  
    #-------------------------------------------------------------------------- 
    def initialize
      super(-20, 170, 320, 360)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.back_opacity = 0
      self.opacity = 0
      self.contents.font.name = $fontface
      self.contents.font.size = 20
      
      self.active = false
      self.index = -1
      
      @column_max = 1
      
      
      
      refresh
    end
    
    #--------------------------------------------------------------------------
    # ● refresh
    #--------------------------------------------------------------------------
    def refresh(etat_quete = 1)
      if self.contents != nil
        self.contents.dispose
        self.contents = nil
      end
      
      @tab_quete = []
      
      # Parcourir la liste des quete en cours
      $pokemon_party.tab_quete.each_key { |id_quete_party|
       # Si la quete est en cours
        if $pokemon_party.tab_quete[id_quete_party][0] == etat_quete
          #@tab_quete.push(id_quete_party)
          @tab_quete.insert(0,id_quete_party)
        end
      }
      
      @item_max = @tab_quete.size
      
      if @item_max > 0
        self.contents = Bitmap.new(width - 32, row_max * 20 -3)
        self.contents.font.name = $fontface
        self.contents.font.size = 18
        self.contents.font.color = Color.new(0,0,0,255)
        
        @tab_quete.sort!
        
        for i in 0...@tab_quete.size
          id_quete_party = @tab_quete[i]
          # Afficher le nom de la quete
          self.contents.draw_text(30, (i * 20) - 4, 250, 20, $data_quete.tab_def_quete[id_quete_party]["nom"])
  
        end
      end
  
      
    #--------------------------------------------------------------------------
    # ● nb_quete
    #--------------------------------------------------------------------------
      def nb_quete()
        return @tab_quete.size
      end
  
    #--------------------------------------------------------------------------
    # ● id_quete
    #--------------------------------------------------------------------------
      def id_quete()
        return @tab_quete[@index]
      end
  
      
    end
    
    #--------------------------------------------------------------------------
    # ● update_cursor_rect
    #    - Permet de modifier la position du rectangle de sélection à chaque cycle
    #--------------------------------------------------------------------------
    def update_cursor_rect
      # Si l'index de focus est inferieur à 0
      if @index < 0
        # Alors effacer le rectangle de sélection
        self.cursor_rect.empty
      else
        # Sinon afficher le rectangle à la position du focus
        self.cursor_rect.set(14, -4 + (20 * @index), 20, 20)
      end
    end
  end
  
    
  
  #==============================================================================
  # ■ Window_Detailquete
  #------------------------------------------------------------------------------
  #  Fenêtre de détail d'une quete
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Window_Detailquete < Window_Base
    #--------------------------------------------------------------------------
    # ● initialize
    #-------------------------------------------------------------------------- 
    def initialize
      super(230, 0, 600, 600)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.back_opacity = 0
      self.opacity = 0
      self.contents.font.name = $fontface
      self.contents.font.size = 20
      self.contents.font.color = Color.new(0,0,0,255)
      
      refresh
    end
    
    #--------------------------------------------------------------------------
    # ● refresh
    #--------------------------------------------------------------------------
    def refresh(id_quete = -1)
      self.contents.clear
      
      return if id_quete == -1 or $data_quete.tab_def_quete[id_quete] == nil
      ligne = 0
      
      # Afficher le descriptif de la quete ( max 8 lignes )
      self.contents.font.italic = true
      self.contents.draw_text(60, (ligne * 20) -2, 290, 47,"Descriptif :" )
      self.contents.font.italic = false
      $data_quete.tab_def_quete[id_quete]["desc"].each { |texte|
        ligne += 1
        texte[-1] = ""
        self.contents.draw_text(0, (ligne * 20) - 2, 324, 47,texte )
        break if ligne == 10
      }
     
      # Afficher Récompense
      ligne += 5
      k = 0
      self.contents.font.italic = true
      self.contents.draw_text(20, (ligne * 20) -2, 290, 20,"Récompense(s) :" )
      self.contents.font.italic = false
      for i in 0...$data_quete.tab_def_quete[id_quete]["gain"].size
        k += 1
        gain = $data_quete.tab_def_quete[id_quete]["gain"][i]
        nbr = gain[1].to_s
        
        if gain[0] == "EXP"
          bitmap = RPG::Cache.icon("Point Exp.png")
          text = "- "
          taille = self.contents.text_size(text).width
          self.contents.draw_text(0, (ligne * 20 + k * 26) -2, 290, 20, text)
          self.contents.blt(taille + 4, (ligne * 20 + k * 26) -6, bitmap, Rect.new(0, 0, 24, 24))
          self.contents.draw_text(taille + 35, (ligne * 20 + k * 26) -2, 290, 20, "Exp +" + nbr)
          bitmap.dispose
        end
        
        if gain[0] == "OBJ"
          item = $data_items[gain[2]]
          bitmap = RPG::Cache.icon(item.icon_name)
          text = "- "
          taille = self.contents.text_size(text).width
          self.contents.draw_text(0, (ligne * 20 + k * 26) -2, 290, 20, text)
          self.contents.blt(taille + 2, (ligne * 20 + k * 26) -6, bitmap, Rect.new(0, 0, 24, 24))
          self.contents.draw_text(taille + 35, (ligne * 20 + k * 26) -2, 290, 20, item.name + " * " + nbr)
          bitmap.dispose
          
        end
        
        if gain[0] == "ARGENT"
          bitmap = RPG::Cache.icon("Argent.png")
          text = "- "
          taille = self.contents.text_size(text).width
          self.contents.draw_text(0, (ligne * 20 + k * 26) -2, 290, 20, text)
          self.contents.blt(taille + 3, (ligne * 20 + k * 26) -6, bitmap, Rect.new(0, 0, 24, 24))
          self.contents.draw_text(taille + 35, (ligne * 20 + k * 26) -2, 290, 20, "$ +" + nbr)
          bitmap.dispose
        end
        
        if gain[0] == "POKE"
          if gain[1].type == Fixnum
            cible = POKEMON_S::Pokemon_Info.name(gain[1])
          elsif gain[1].type == String
            cible = gain[1]
          end
          bitmap = RPG::Cache.icon("pokeball.png")
          text = "- "
          taille = self.contents.text_size(text).width
          self.contents.draw_text(0, (ligne * 20 + k * 26) -2, 290, 20, text)
          self.contents.blt(taille + 2, (ligne * 20 + k * 26) -6, bitmap, Rect.new(0, 0, 24, 24))
          self.contents.draw_text(taille + 35, (ligne * 20 + k * 26) -2, 290, 20, cible + " niveau " + gain[2].to_s)
          bitmap.dispose
        end
        
      end
      
      # Afficher objectif
      ligne -= 1
      self.contents.font.italic = true
      self.contents.draw_text(20, (ligne * 20) -2, 290, 380,"Objectif(s) :" )
      self.contents.font.italic = false
      
      for i in 0...$data_quete.tab_def_quete[id_quete]["but"].size
        objectif = $data_quete.tab_def_quete[id_quete]["but"][i]
        fait = $pokemon_party.tab_quete[id_quete][1][i]
        sur = objectif[1]
        ligne += 1
        
        if $pokemon_party.quete_objectif_termine?(id_quete,i)
          self.contents.font.color = Color.new(100,100,100,255)
        end
        
        if objectif[0] == "VOIR"
          if objectif[2].type == Fixnum
            cible = $data_enemies[objectif[2]].name
          elsif objectif[2].type == String
            cible = objectif[2]
          end
          type = "- Vus " + fait.to_s + "/" + sur.to_s + " " + cible
          self.contents.draw_text(0, (ligne * 20) -2, 310, 400, type )
        end
        
        if objectif[0] == "CAPTURER"
          if objectif[2].type == Fixnum
            cible = $data_enemies[objectif[2]].name
          elsif objectif[2].type == String
            cible = objectif[2]
          end
          type = "- Capturer " + fait.to_s + "/" + sur.to_s + " " + cible
          self.contents.draw_text(0, (ligne * 20) -2, 310, 400, type )
        end
        
        if objectif[0] == "VAINCRE"
          if objectif[2].type == Fixnum
            cible = $data_enemies[objectif[2]].name
          elsif objectif[2].type == String
            cible = objectif[2]
          end
          type = "- Vaincus " + fait.to_s + "/" + sur.to_s + " " + cible
          self.contents.draw_text(0, (ligne * 20) -2, 310, 400, type )
        end
        
        if objectif[0] == "TR_OBJ"
          item = $data_items[objectif[2]]
          bitmap = RPG::Cache.icon(item.icon_name)
          fait = ( fait > sur ? sur : fait)
          text = "- Trouver " + fait.to_s + "/" + sur.to_s
          taille = self.contents.text_size(text).width
          self.contents.draw_text(0, (ligne * 20) -2, 310, 400, text)
          self.contents.blt(taille + 4, (ligne * 20) + 183, bitmap, Rect.new(0, 0, 24, 24))
          self.contents.draw_text(taille + 30, (ligne * 20) -2, 310, 400, item.name)
          bitmap.dispose
        end
        
        if objectif[0] == "PARLER"
          self.contents.draw_text(0, (ligne * 20) -2, 310, 400, "- Parler " + objectif[1])
        end
        
        self.contents.font.color = Color.new(0,0,0,255)
        
      end
      
    end
  end
  
  
  
  #==============================================================================
  # ■ Scene_Quete
  #------------------------------------------------------------------------------
  #  Gérer les quetes
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #
  #==============================================================================
  class Scene_Quete
    
    #--------------------------------------------------------------------------
    # ● main
    #-------------------------------------------------------------------------- 
    def main
      # Création des fenêtres
      @optionquete_window = Window_Optionquete.new
      @listequete_window = Window_Listequete.new
      @detailquete_window = Window_Detailquete.new
  
      # Affichage image de fond
      @img_fond = Sprite.new
      @img_fond.bitmap = RPG::Cache.picture(DATA_QUETES[:interface_journal]) 
      
      # Effectuer la transition graphique
      Graphics.transition
      # Boucle
      loop do
        # Mettre à jour les graphique
        Graphics.update
        # Mettre à jour les entrés clavier
        Input.update 
        # Appeler fonction update
        update
        # si la Scene n'est plus la même
        if $scene != self
          # Alors sortir de la boucle
          break
        end
      end
      Graphics.freeze
      
      # Détruire objets de classe
      @optionquete_window.dispose
      @listequete_window.dispose
      @detailquete_window.dispose
      
      # destruction de l'image de fond
      @img_fond.bitmap.dispose
      @img_fond.dispose
    end
    
    #--------------------------------------------------------------------------
    # ● update
    #--------------------------------------------------------------------------
    def update
      # Mettre à jour les fenêtres
      @optionquete_window.update
      @listequete_window.update
      @detailquete_window.update
      
      if @optionquete_window.active
        gerer_menu
      elsif @listequete_window .active
        gerer_liste
      end
      
    end
    
    #--------------------------------------------------------------------------
    # ● gerer_menu
    #--------------------------------------------------------------------------
    def gerer_menu
      
      # si la touche B est appuyée
      if Input.trigger?(Input::B)
        # Alors, jouer le son "cancel"
        $game_system.se_play($data_system.cancel_se)
        # Revenir sur l'écran de compte
        $scene = POKEMON_S::Pokemon_Menu.new(0)
        return
      end
      
      # Si la fleche bas ou la fleche bas est appuyée
      if Input.trigger?(Input::DOWN) or Input.trigger?(Input::UP)
        @listequete_window.refresh(@optionquete_window.index + 1)
      end
      
      # si la touche C est appuyée
      if Input.trigger?(Input::C)
        # ne rien faire si il n'y a pas de quete
        return if @listequete_window.nb_quete() == 0
        # Alors, jouer le son "decision"
        $game_system.se_play($data_system.decision_se)
        # Parcourir la liste des quetes
        @optionquete_window.active = false
        @listequete_window.active = true
        @listequete_window.index = 0
        @detailquete_window.refresh(@listequete_window.id_quete)
      end
      
    end
  
    #--------------------------------------------------------------------------
    # ● gerer_liste
    #--------------------------------------------------------------------------
    def gerer_liste
      # Si la fleche bas ou la fleche bas est appuyée
      if Input.trigger?(Input::DOWN) or Input.trigger?(Input::UP)
        @detailquete_window.refresh(@listequete_window.id_quete)
      end
      
      # si la touche B est appuyée
      if Input.trigger?(Input::B)
        # Alors, jouer le son "cancel"
        $game_system.se_play($data_system.cancel_se)
        # Revenir sur le sommaire
        @listequete_window.active = false
        @optionquete_window.active = true
        @listequete_window.index = -1
        @detailquete_window.refresh
        return
      end
    end
  end