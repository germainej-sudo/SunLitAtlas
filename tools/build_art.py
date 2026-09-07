"""Deterministic original pixel assets. Requires Pillow only to regenerate."""
from PIL import Image,ImageDraw
from pathlib import Path
import random,json,math,wave,struct
R=Path(__file__).resolve().parents[1]; A=R/'assets'; A.mkdir(exist_ok=True)
def rect(d,box,c):d.rectangle(tuple(int(v) for v in box),fill=c)
def sprite(name,w,h,paint):
 im=Image.new('RGBA',(w,h)); d=ImageDraw.Draw(im);paint(d); im.save(A/(name+'.png'))
def tree(d):
 rect(d,(28,55,37,83),'#73543b');rect(d,(32,57,36,80),'#a17743')
 for b,c in [((7,60,60,78),'#214e4938'),((9,20,57,63),'#22664e'),((4,25,60,48),'#2b8150'),((12,9,53,51),'#368f4f'),((21,3,44,41),'#469b51')]:rect(d,b,c)
 rng=random.Random(19)
 for _ in range(80):
  x=rng.randrange(12,53);y=rng.randrange(13,58);s=rng.randrange(3,9);rect(d,(x,y,x+s,y+s),rng.choice(['#439a50','#51a857','#2b7b4c','#358c48']))
 rect(d,(18,10,32,15),'#69b65b')
sprite('tree',68,86,tree)
def house(d):
 rect(d,(10,115,180,133),'#264d3c35');rect(d,(14,42,174,121),'#c9b888');rect(d,(21,47,169,115),'#eadba6')
 for y in range(48,113,11):
  for x in range(23+(y%3)*5,166,27):rect(d,(x,y,x+17,y+6),'#dfcf99')
 rect(d,(77,84,103,121),'#765139');rect(d,(80,86,99,118),'#886346');rect(d,(95,104,97,106),'#caa362')
 for x in [35,126]:
  rect(d,(x-2,64,x+22,89),'#fff0b9');rect(d,(x,66,x+20,87),'#284c67');rect(d,(x+9,66,x+11,87),'#ded5a4');rect(d,(x,76,x+20,78),'#ded5a4')
  rect(d,(x-6,91,x+27,101),'#99704a')
  for xx in range(x-4,x+26,6):rect(d,(xx,87,xx+5,94),'#38894d');rect(d,(xx+2,85,xx+4,88),'#fff3bf')
 rect(d,(7,10,184,47),'#b84f3f');rect(d,(9,5,181,40),'#d8664b')
 for y in range(9,42,8):
  for x in range(10+(y%3)*7,180,22):rect(d,(x,y,x+19,y+5),['#d96b50','#ce5c44','#c45540'][(x+y)%3])
 rect(d,(7,43,184,49),'#974c3b');rect(d,(67,56,74,88),'#3686a3');rect(d,(108,56,115,88),'#3686a3')
 rect(d,(68,66,72,70),'#f4cc65');rect(d,(109,66,113,70),'#f4cc65')
sprite('house',192,140,house)
def prop(d):
 rect(d,(7,27,43,35),'#4f583840');rect(d,(10,23,14,34),'#765135');rect(d,(35,23,39,34),'#765135');rect(d,(7,5,43,26),'#9d7649');rect(d,(10,7,41,23),'#dccc92')
 for x,y in [(16,12),(25,16),(33,12)]:rect(d,(x,y,x+5,y+4),'#6f9d69')
sprite('table',50,38,prop)
def lamp(d):
 rect(d,(11,16,14,53),'#665748');rect(d,(8,51,18,57),'#6a6d56');rect(d,(6,6,20,22),'#224954');rect(d,(9,9,17,19),'#ffd575');rect(d,(11,11,15,16),'#fff4b8');rect(d,(9,2,17,6),'#2c4651')
sprite('lamp',28,60,lamp)
def stone(d):
 rect(d,(2,20,31,29),'#29433a35');rect(d,(4,6,29,25),'#a9ac91');rect(d,(7,3,25,22),'#d4cfac');rect(d,(12,8,20,16),'#b59354');rect(d,(15,6,17,19),'#f5d783');rect(d,(10,11,22,13),'#f5d783')
sprite('stone',34,32,stone)
def chest(d):
 rect(d,(2,8,29,29),'#795234');rect(d,(4,5,27,25),'#aa7b48');rect(d,(3,12,28,15),'#624e34');rect(d,(7,5,9,25),'#d5b36e');rect(d,(23,5,25,25),'#d5b36e');rect(d,(14,12,18,18),'#f0ce77')
sprite('chest',32,32,chest)
def flowers(d):
 rect(d,(0,24,53,34),'#8b6b44');rect(d,(2,9,51,26),'#3e8e50')
 for x,y,c in [(8,11,'#fff3b8'),(21,8,'#ef8f70'),(35,11,'#fff3b8'),(44,19,'#f8d168'),(17,22,'#fff3b8')]:
  rect(d,(x-3,y-1,x+3,y+1),c);rect(d,(x-1,y-3,x+1,y+3),c);rect(d,(x,y,x+1,y+1),'#e9bd53')
sprite('flowers',54,36,flowers)
def gate(d):
 for x in [4,76]:rect(d,(x,7,x+16,79),'#d8ccaa');rect(d,(x-3,5,x+19,16),'#efe1b4');rect(d,(x+4,32,x+12,60),'#39849d');rect(d,(x+6,42,x+10,46),'#f6d372')
 for x in range(24,74,8):rect(d,(x,23,x+3,68),'#30504b')
 rect(d,(23,30,76,33),'#30504b');rect(d,(23,62,76,65),'#30504b')
sprite('gate',100,84,gate)
# 4 directions x 4 walk frames. Native size 24x32; distinct silhouettes.
for name,coat in [('liora','#288a98'),('purple','#8658a3'),('green','#58844b'),('red','#c65e43'),('blue','#386d91')]:
 im=Image.new('RGBA',(96,128));d=ImageDraw.Draw(im)
 for direction in range(4):
  for f in range(4):
   x=f*24;y=direction*32;bob=1 if f in (1,3) else 0
   def b(v,c):rect(d,(x+v[0],y+v[1]+bob,x+v[2],y+v[3]+bob),c)
   b((5,28,20,30),'#22483b55');b((7,24+(f==1),10,29),'#554c3b');b((15,24+(f==3),18,29),'#554c3b');b((7,14,18,25),coat);b((5,16,7,23),coat);b((19,16,21,23),coat)
   b((8,5,18,14),'#bc7e50' if name=='liora' else '#deb182');b((7,3,18,7),'#362f2b');b((5,6,8,12),'#362f2b');b((17,6,20,10),'#362f2b');b((10 if direction!=2 else 8,9,11 if direction!=2 else 9,10),'#263637')
   if direction==3:b((8,6,18,13),'#362f2b')
   if name=='liora':b((8,14,18,16),'#e8855e');b((15,15,17,21),'#e8855e');b((3,10,6,19),'#3f302a');b((19,19,22,22),'#f4cd6c')
   else:b((7,17,18,18),'#e4c685')
 im.save(A/(name+'.png'))

def bench(d):
 for y in [5,11,17]:rect(d,(2,y,43,y+4),'#997044')
 rect(d,(4,22,7,29),'#684b34');rect(d,(37,22,40,29),'#684b34');rect(d,(0,21,45,24),'#b18c57')
sprite('bench',48,32,bench)
def market(d):
 rect(d,(8,28,12,79),'#816140');rect(d,(83,28,87,79),'#816140');rect(d,(6,54,90,69),'#ab834c')
 for x in range(2,96,12):rect(d,(x,7,x+11,33),'#3a8b9b' if x%24==2 else '#eee1b6')
 for x in range(14,80,15):rect(d,(x,47,x+11,54),'#d99b53');rect(d,(x+2,44,x+8,49),'#cc7650')
sprite('market',100,84,market)
def pillar(d):
 rect(d,(5,59,44,68),'#5c6b5b35');rect(d,(11,10,35,58),'#cecfb0');rect(d,(16,12,20,54),'#eaE2bc');rect(d,(4,5,42,14),'#e5dbb7');rect(d,(7,53,40,61),'#babd9b');rect(d,(22,21,30,31),'#54a4a0')
sprite('pillar',48,72,pillar)
def tower(d):
 rect(d,(12,115,92,130),'#405b5138');rect(d,(23,33,77,119),'#e5dcb8')
 for y in range(43,115,13):rect(d,(24,y,76,y+2),'#c8cbb0')
 rect(d,(18,30,82,45),'#c36c51');rect(d,(26,8,74,31),'#355d65');rect(d,(31,12,69,28),'#f8d580');rect(d,(45,12,53,28),'#fff1b2');rect(d,(19,3,82,10),'#7d6350');rect(d,(41,94,59,119),'#7e6147')
sprite('tower',104,136,tower)
def wheel(d):
 d.ellipse((2,2,60,60),fill='#725937');d.ellipse((7,7,55,55),fill='#bb9459');d.ellipse((13,13,49,49),fill='#398ca8')
 for i in range(8):
  a=i*math.pi/4;d.line((31,31,31+26*math.cos(a),31+26*math.sin(a)),fill='#d3b371',width=5)
 d.ellipse((25,25,37,37),fill='#765a39')
sprite('wheel',64,64,wheel)
def shelves(d):
 rect(d,(2,2,90,65),'#6f573e')
 for y in [9,29,49]:
  for x in range(7,86,7):rect(d,(x,y,x+4,y+12),['#cd9a63','#629698','#b5b66e','#cb7960'][x%4])
  rect(d,(4,y+14,89,y+17),'#b68b52')
sprite('shelves',94,70,shelves)

world=json.loads((R/'data/world.json').read_text());layout={}
for index,(id,r) in enumerate(world['rooms'].items()):
 rng=random.Random(100+index);theme=r['theme'];inside=theme in ('interior','under');w,h=960,540
 colors={'town':('#79b85a','#e4cf8c'),'forest':('#6daa50','#c6bd78'),'river':('#78ac61','#ded198'),'ruins':('#a6b891','#d8cfaa'),'coast':('#81b790','#e6d69e'),'island':('#78ac81','#eadba5'),'mountain':('#bdb875','#e2d6b2'),'interior':('#73694f','#b39a6e'),'under':('#455b51','#8e9174')};grass,path=colors[theme]
 im=Image.new('RGB',(w,h),grass);d=ImageDraw.Draw(im)
 for y in range(0,h,16):
  for x in range(0,w,16):
   rgb=tuple(max(0,min(255,v+rng.randint(-6,6))) for v in __import__('PIL').ImageColor.getrgb(grass));rect(d,(x,y,x+15,y+15),rgb)
 for _ in range(8000):
  x=rng.randrange(w);y=rng.randrange(h);c=rng.choice(['#bad16a','#78b356','#6ca24f']) if theme=='forest' else tuple(max(0,min(255,v+rng.randint(-15,15))) for v in __import__('PIL').ImageColor.getrgb(grass));rect(d,(x,y,x+1,y+1),c)
 # Broad central plaza and branching roads keep objects reachable.
 rect(d,(85,245,900,323),path);rect(d,(426,75,524,510),path);rect(d,(270,172,765,406),path)
 if theme in ('town','ruins','interior','under'):
  for y in range(176,403,16):
   for x in range(272+(8 if (y//16)%2 else 0),759,24):
    rgb=tuple(max(0,min(255,v+rng.randint(-9,7))) for v in __import__('PIL').ImageColor.getrgb(path));rect(d,(x,y,x+22,y+14),rgb)
 if inside:
  rect(d,(80,65,880,140),'#665b4c');rect(d,(94,77,866,128),'#9a8767');rect(d,(80,130,880,143),'#443f36');rect(d,(85,440,880,461),'#665b4c')
 if theme in ('town','river','coast','island'):
  # Water stays outside walkways; bridges are explicit gaps in the banks.
  xx=805 if theme=='town' else 790
  rect(d,(xx,0,xx+72,h),'#338bb2')
  for _ in range(170):
   x=rng.randrange(xx+4,xx+65);y=rng.randrange(h);rect(d,(x,y,x+rng.randrange(3,10),y+1),rng.choice(['#439dc0','#55a9c7','#287ca5']))
  for y0,y1 in [(190,330),(375,450)]:
   rect(d,(xx-8,y0,xx+79,y1),'#b9b38f')
   for x in range(xx-4,xx+76,8):rect(d,(x,y0+2,x+1,y1-2),'#d6cba5')
  for yy in range(0,h,16):
   if not 180<yy<460:rect(d,(xx-8,yy,xx-1,yy+14),'#d4cca8');rect(d,(xx+72,yy,xx+79,yy+14),'#d4cca8')
 decor=[];coll=[]
 def deco(asset,x,y,box=None):
  decor.append(dict(asset=asset,x=x,y=y))
  if box:coll.append([x+box[0],y+box[1],box[2],box[3]])
 # Water collision mirrors painted channels and bridge gaps.
 if theme in ('town','river','coast','island'):
  for y0,y1 in [(0,190),(330,375),(450,540)]:coll.append([xx,y0,72,y1-y0])
 if id=='town':
  deco('house',480,160,[-77,-78,153,68]);deco('house',220,182,[-77,-78,153,68]);deco('house',140,470,[-77,-78,153,68]);deco('gate',890,250)
 elif not inside:
  if id in ('forest','river'):deco('house',230 if id=='forest' else 250,155,[-77,-78,153,68])
  if id=='ruins':deco('house',480,150,[-77,-78,153,68])
  if id=='coast':deco('tower',480,220,[-24,-78,48,68])
 # Decoration excluded from all gameplay and door approaches.
 occupied=[(o['x'],o['y']) for o in r['objects']]+[(o['x'],o['y']) for o in r['exits']]
 if not inside:
  for _ in range(70):
   x=rng.randrange(45,920);y=rng.randrange(75,510)
   if (260<x<775 and 165<y<420) or (410<x<545) or (235<y<345) or (theme in ('town','river','coast','island') and 785<x<885):continue
   if any(abs(x-ox)<90 and abs(y-oy)<95 for ox,oy in occupied):continue
   if any(abs(x-z['x'])<45 and abs(y-z['y'])<45 for z in decor):continue
   deco('tree',x,y,[-10,-18,20,17])
 for x,y in [(290,170),(750,170),(290,425),(740,430)]:deco('lamp',x,y)
 for x,y in [(350,155),(610,155),(325,435),(630,435)]:deco('flowers',x,y)
 for x,y in [(330,150),(660,150)]:
  if id=='town':
   d.line((x,y,x+160,y+18),fill='#99794c',width=1)
   for j in range(7):d.polygon([(x+j*23,y+j*2),(x+j*23+14,y+j*2+2),(x+j*23+7,y+j*2+19)],fill=['#df7557','#368fa8','#f0c653'][j%3])
 # Authored regional landmarks and lived-in perimeter details.
 if id=='town':
  deco('market',715,478);deco('bench',345,397);deco('bench',660,440)
  for x,y in [(80,340),(170,230),(610,450),(915,435)]:deco('flowers',x,y)
 if id=='forest':
  deco('tree',617,180,[-10,-18,20,17]);deco('tree',709,180,[-10,-18,20,17]);deco('bench',350,430)
 if theme in ('ruins','under'):
  for x,y in [(330,155),(650,155),(325,435),(685,435)]:deco('pillar',x,y)
 if id=='coast':deco('market',640,460)
 if id in ('river','sluice'):deco('wheel',730,175)
 if inside:
  for x in [260,420,650,790]:deco('shelves',x,125)
  deco('bench',330,375);deco('bench',620,375)
 if theme=='island':deco('tower',650,145)
 if theme=='mountain':
  for x,y in [(390,135),(590,135),(650,400)]:deco('pillar',x,y)
 for o in r['objects']:
  if o['kind']=='npc':continue
  deco('table' if o['kind']=='puzzle' else 'flowers' if o['kind']=='rest' else 'stone' if o['kind']=='evidence' else 'chest',o['x'],o['y'])
 if theme not in ('town','ruins','interior','under'):
  path_rgb=__import__('PIL').ImageColor.getrgb(path)
  for _ in range(22000):
   x=rng.randrange(w);y=rng.randrange(h)
   if im.getpixel((x,y))==path_rgb:
    offset=rng.choice([-9,-5,5,9]);rect(d,(x,y,x+1,y),tuple(max(0,min(255,v+offset)) for v in path_rgb))
 im.save(A/(id+'.png'));layout[id]=dict(decor=decor,collision=coll)
(R/'data/layout.json').write_text(json.dumps(layout))
# Gentle original looping pentatonic themes. No external sound dependency.
rate=22050
for name,base in [('village',60),('wilds',57),('mystery',62),('ending',65)]:
 notes=[0,7,12,9,7,4,2,7,0,4,9,12,7,4,2,0];samples=[];beat=.32
 for i,n in enumerate(notes*2):
  freq=440*2**((base+n-69)/12)
  for k in range(int(rate*beat)):
   t=k/rate;env=min(1,t/.02)*max(0,1-t/beat)**1.8
   tone=math.sin(2*math.pi*freq*t)*.11+math.sin(2*math.pi*(freq/2)*t)*.04
   pad=math.sin(2*math.pi*(440*2**((base-12-69)/12))*(i*beat+t))*.025
   samples.append(int(32767*(tone*env+pad)))
 with wave.open(str(A/(name+'.wav')),'w') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
print('Generated pixel environments, animated characters, props, and four original music loops.')
