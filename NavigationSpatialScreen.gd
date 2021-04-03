extends Spatial
class_name NavigationSpatialScreen
# MIT License
# Copyright (c) 2021 liss22
# 3d 화면 네비게이터
# anchor_h/anchor_v/camera 로 구성된 3d 개체 필요합니다.
# 각 변수에 객체를 등록 후
# three_finger_reset_info() 에 리셋 정보를 입력하여 사용합니다.

# 마우스 포인터들 관리
# indexes
var touches:Dictionary={}
# center, dist
var tmp:Dictionary={}
# 격차 조정
const SCALED_TRANSLATE:=100

var anchor_h:Spatial
var anchor_v:Spatial
var camera:Camera

func _input(event):
	# 터치 시작과 종료
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var index = 0 if event is InputEventMouseButton else event.index
		if event.pressed: # 등록과 삭제
			touches[index] = event.position
		else:
			touches.erase(index)
			tmp.clear()
		if touches.size() > 2: # 기본값으로 복구
			reset_view_info()
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		var touches_length:=touches.size()
		var index = 0 if event is InputEventMouseMotion else event.index
		if touches_length == 1: # 회전
			var last_info:Vector2=touches[index]
			anchor_h.rotate_y(-deg2rad(event.position.x - last_info.x))
			anchor_v.rotate_x(-deg2rad(event.position.y - last_info.y))
			touches[index] = event.position
		elif touches_length == 2: # 스케일, 패닝
			var last_other:Vector2=touches[1 if index == 0 else 0]
			var dist:=last_other.distance_to(event.position)
			var center:Vector2 = (last_other + event.position) / 2
			# 사전 등록값이 있을 때만 연산
			if tmp.size():
				camera.translate_object_local(Vector3(-(center - tmp['center']).x/SCALED_TRANSLATE,(center - tmp['center']).y/SCALED_TRANSLATE,0))
				camera.fov = clamp(camera.fov - (dist - tmp['dist'])/2, 30, 95)
			tmp['center'] = center
			tmp['dist'] = dist
			touches[index] = event.position

func three_finger_reset_info():
	printerr('three_finger_reset_info 설정되지 않음')

func reset_view_info():
	three_finger_reset_info()
#	# 잠시 대기시킴
	set_process_input(false)
	yield(get_tree().create_timer(.6),"timeout")
	set_process_input(true)
