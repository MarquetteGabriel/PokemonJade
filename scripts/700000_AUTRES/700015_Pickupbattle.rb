#----------------------------
#  Ramassage\Pickup
#  Par FL0RENT_
#----------------------------
def pickup
  for p in $pokemon_party.actors
    if p.ability_symbol == :ramassage and p.item_hold == 0
      if rand(100) < 10
        a = p.level/10
        r = rand(100)
        b = 0
        for n in [30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
          b += 1 if r >= n
        end
        p.item_hold = PICKUP_TABLE[a][b]
      end
    end
  end
end
 
   
 
PICKUP_TABLE = [
[13, 17, 14, 3, 70, 73, 22, 15, 2, 22, 190], # 1 - 10
[17, 14, 3, 70, 73, 22, 15, 2, 24, 190, 98], # 11 - 20
[14, 3, 70, 73, 22, 15, 2, 24, 41, 98, 23], # 21 - 30
[3, 70, 73, 22, 15, 2, 24, 41, 59, 23, 28], # 31 - 40
[70, 73, 22, 15, 2, 24, 41, 59, 60, 28, 93], # 41 - 50
[73, 22, 15, 2, 24, 41, 59, 60, 191, 93, 161], # 51 - 60
[22, 15, 2, 24, 41, 59, 60, 191, 23, 161, 28], # 61 - 70
[15, 2, 24, 41, 59, 60, 191, 23, 25, 28, 118], # 71 - 80
[2, 24, 41, 59, 60, 191, 23, 25, 48, 118, 102], # 81 - 90
[2, 24, 41, 59, 60, 191, 23, 25, 48, 49, 143]  # 91 - 100
]