extends Spatial 

# SHOOTING - : the different technics
# 1. Bullet Object
# 2. Bullet Raycast

# MARKUP - : Properties
const killTimer   = 10
var bulletSpeed   = 10
var bulletDamage  = 5
var timer         = 0
var hitSomething  = false 


# MARKUP - : Properties
func _ready() :
   $Area.connect("body_entered", self, "collided")
   # .connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)


# MARKUP - : Functions
func _physics_process(delta) :
   var forwardDirection = global_transform.basis.z.normalized()
   global_translate(forwardDirection * bulletSpeed * delta)
   
   timer += delta
   if timer >= killTimer:
      queue_free()
      
func collided(body):
   if hitSomething == false :
      if body.has_method("bulletHit") :
         var damage = bulletDamage
         body.bulletHit(damage, global_transform)
         
      hitSomething = true
      queue_free()
