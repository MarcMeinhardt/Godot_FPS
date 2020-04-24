extends Spatial

# Simple Audio Player as performance is not taken in to account

# MARKUP - : Properties

# All of the audio files
# You will need to provide your own audio files
var audioPistolShot  = preload("res://assets/Game_Level_Objects/assets/audio/Gamemaster Audio -  Gun Sound Pack/gun_revolver_pistol_shot_04.wav")
var audioGunCock     = preload("res://assets/Game_Level_Objects/assets/audio/Gamemaster Audio -  Gun Sound Pack/gun_semi_auto_rifle_cock_02.wav")
var audioRifleShot   = preload("res://assets/Game_Level_Objects/assets/audio/Gamemaster Audio -  Gun Sound Pack/gun_revolver_pistol_shot_04.wav")

var audioNode = null

# MARKUP - : Ready

func _ready() :
   audioNode = $Audio_Stream_Player
   audioNode.connect("finished", self, "destroySelf")
   audioNode.stop()
 
# MARKUP - : Functions  

func playSound(soundName, position = null) :
   if audioPistolShot == null or audioRifleShot == null or audioGunCock == null :
      print("no audio set")
      queue_free()
      return

   if soundName == "PistolShot" : 
      audioNode.stream = audioPistolShot
   elif soundName == "RifleShot" :
      audioNode.stream = audioRifleShot
   elif soundName == "GunCock" :
      audioNode.stream = audioGunCock
   else :
      print("unknown stream")
      queue_free()
      return
   
   # AudioStreamPlayer3D methods : 
   if audioNode is AudioStreamPlayer3D :
      if position != null :
         audioNode.global_transform.origin = position
         
   audioNode.play()
   
   
func destroySelf() :
   audioNode.stop()
   queue_free()
      
