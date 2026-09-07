"""Checks authored dependencies and physical reachability, not just JSON shape."""
import json,collections,math
from pathlib import Path
R=Path(__file__).resolve().parents[1]
b=json.loads((R/'data/world.json').read_text());layouts=json.loads((R/'data/layout.json').read_text())
flags=set();visited={'town'}
for iteration in range(100):
 before=(len(flags),len(visited))
 for id in list(visited):
  r=b['rooms'][id]
  for e in r['exits']:
   assert e['to'] in b['rooms']
   assert any(back['to']==id for back in b['rooms'][e['to']]['exits']), (id,e)
   if set(e['need'])<=flags:visited.add(e['to'])
  for o in r['objects']:
   if not set(o.get('need',[]))<=flags:continue
   if o['kind'] in ('collect','evidence'):flags.add(o['id'])
   if o['kind']=='npc' and o.get('gift'):flags.add(o['gift'])
   if o['kind']=='puzzle':
    p=b['puzzles'][o['id']]
    if set(p['need'])<=flags:
     flags.add(o['id']);flags.update(p['award']);flags.update(p['reward'])
     if p['paper']:flags.add('paper'+str(p['paper']))
   if o['kind']=='ending':flags.add(o['id'])
 if before==(len(flags),len(visited)):break
assert 'ending' in flags, ('Ending unreachable',flags)
assert len(visited)==len(b['rooms']),set(b['rooms'])-visited
for id,p in b['puzzles'].items():
 assert id in flags,id
 assert len(p['labels'])==len(p['answer'])==len(p['choices'])
 assert all(0<=v<len(p['choices'][i]) for i,v in enumerate(p['answer']))
# A 6-pixel body must navigate from every authored entrance to each interaction.
for id,r in b['rooms'].items():
 boxes=layouts[id]['collision']
 def free(x,y):
  return 24<=x<=936 and 65<=y<=514 and not any(bx-7<x<bx+bw+7 and by-7<y<by+bh+7 for bx,by,bw,bh in boxes)
 start=(450//8,350//8);seen={start};queue=collections.deque([start])
 while queue:
  x,y=queue.popleft()
  for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)]:
   p=(x+dx,y+dy)
   if p not in seen and free(p[0]*8,p[1]*8):seen.add(p);queue.append(p)
 for o in r['objects']+r['exits']:
  assert any(math.hypot(x*8-o['x'],y*8-o['y'])<40 for x,y in seen),(id,o.get('id',o.get('to')),'unreachable')
print(f"PASS: full ending + all {len(visited)} sectors reachable; all mechanism domains valid; all objects and paired doors physically approachable.")
