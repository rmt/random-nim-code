#
# volctl wraps libasound in order to set the mixer volume of a device
#
# License: MIT
#

import os
import system/ansi_c

type
  snd_pcm_t = distinct pointer
  snd_ctl_t = distinct pointer
  snd_ctl_card_info_t = distinct pointer
  snd_pcm_info_t = distinct pointer
  snd_mixer_t = distinct pointer
  snd_mixer_elem_t = distinct pointer

  SND_PCM_STREAM = enum
    SND_PCM_STREAM_PLAYBACK = 0
    SND_PCM_STREAM_CAPTURE = 1

  SND_MIXER_CHANNEL = enum
    SND_MIXER_SCHN_UNKNOWN = -1
    SND_MIXER_SCHN_FRONT_LEFT = 0
    SND_MIXER_SCHN_FRONT_RIGHT
    SND_MIXER_SCHN_REAR_LEFT
    SND_MIXER_SCHN_FRONT_CENTER
    SND_MIXER_SCHN_WOOFER
    SND_MIXER_SCHN_SIDE_RIGHT
    SND_MIXER_SCHN_REAR_CENTER
    SND_MIXER_SCHN_LAST

const SND_MIXER_SCHN_MONO = SND_MIXER_SCHN_FRONT_LEFT

{.push cdecl, dynlib: "libasound.so", importc.}
proc snd_card_next(card: var cint): cint
proc snd_ctl_open(ctl: var snd_ctl_t, cardname: cstring, mode: cint): cint
proc snd_ctl_card_info(ctl: snd_ctl_t, info: snd_ctl_card_info_t): cint
proc snd_ctl_close(ctl: snd_ctl_t)
proc snd_ctl_card_info_get_name(info: snd_ctl_card_info_t): cstring
proc snd_ctl_card_info_get_driver(info: snd_ctl_card_info_t): cstring
proc snd_ctl_pcm_next_device(ctl: snd_ctl_t, device: var cint): cint
proc snd_ctl_pcm_info(ctl: snd_ctl_t, pcminfo: snd_pcm_info_t): cint
proc snd_pcm_info_set_device(pcminfo: snd_pcm_info_t, val: cuint)
proc snd_pcm_info_set_subdevice(pcminfo: snd_pcm_info_t, val: cuint)
proc snd_pcm_info_set_stream(pcminfo: snd_pcm_info_t, val: SND_PCM_STREAM)
proc snd_pcm_info_get_name(pcminfo: snd_pcm_info_t): cstring
proc snd_mixer_open(mixer: var snd_mixer_t, mode: cint): cint
proc snd_mixer_attach(mixer: snd_mixer_t, cardname: cstring): cint
proc snd_mixer_selem_register(mixer: snd_mixer_t, regopt: pointer, classp: pointer): cint
proc snd_mixer_load(mixer: snd_mixer_t): cint
proc snd_mixer_first_elem(mixer: snd_mixer_t): snd_mixer_elem_t
proc snd_mixer_elem_next(mixer: snd_mixer_elem_t): snd_mixer_elem_t
proc snd_mixer_selem_get_name(elem: snd_mixer_elem_t): cstring
proc snd_mixer_selem_get_index(elem: snd_mixer_elem_t): cuint
proc snd_mixer_selem_has_playback_volume(elem: snd_mixer_elem_t): cint
proc snd_mixer_selem_has_capture_volume(elem: snd_mixer_elem_t): cint
#proc snd_mixer_selem_get_capture_volume_range(elem: snd_mixer_elem_t, min: var clong, max: var clong)
#proc snd_mixer_selem_get_playback_volume_range(elem: snd_mixer_elem_t, min: var clong, max: var clong)
#proc snd_mixer_selem_set_playback_volume_all(elem: snd_mixer_elem_t, value: clong): cint
#proc snd_mixer_selem_set_playback_volume(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: clong): cint
#proc snd_mixer_selem_get_playback_volume(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: var clong): cint
proc snd_mixer_selem_get_playback_dB_range(elem: snd_mixer_elem_t, min: var clong, max: var clong)
proc snd_mixer_selem_get_capture_dB_range(elem: snd_mixer_elem_t, min: var clong, max: var clong)
proc snd_mixer_selem_get_playback_dB(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: var clong): cint
proc snd_mixer_selem_get_capture_dB(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: var clong): cint
proc snd_mixer_selem_set_playback_dB(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: clong, dir: int): cint
proc snd_mixer_selem_set_capture_dB(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: clong, dir: int): cint
proc snd_mixer_selem_set_playback_dB_all(elem: snd_mixer_elem_t, value: clong, dir: int): cint
proc snd_mixer_selem_set_capture_dB_all(elem: snd_mixer_elem_t, value: clong, dir: int): cint
proc snd_mixer_selem_get_playback_switch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: var cint): cint
proc snd_mixer_selem_set_playback_switch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: cint): cint
proc snd_mixer_selem_set_playback_switch_all(elem: snd_mixer_elem_t, value: cint): cint
proc snd_mixer_selem_get_capture_switch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: var cint): cint
proc snd_mixer_selem_set_capture_switch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: cint): cint
proc snd_mixer_selem_set_capture_switch_all(elem: snd_mixer_elem_t, value: cint): cint
proc snd_mixer_close(mixer: snd_mixer_t): cint
proc snd_strerror(errnum: cint): cstring
{.pop.}

iterator alsaCards*(): tuple[cardname: string, cardinfo: snd_ctl_card_info_t] =
  var ctl: snd_ctl_t
  var cardidx: cint = -1
  var cardinfo = snd_ctl_card_info_t(c_malloc(1024))  # no idea of the real size
  defer: c_free(pointer(cardinfo))

  while snd_card_next(cardidx) == 0 and cardidx >= 0:
    let cardname: string = "hw:" & $cardidx
    var err = snd_ctl_open(ctl, cardname, 0)
    if err < 0:
      echo "Could not open card ", cardname, ": ", snd_strerror(err)
      continue
    err = snd_ctl_card_info(ctl, cardinfo)
    yield (cardname, cardinfo)

proc name*(cardinfo: snd_ctl_card_info_t): string =
  if pointer(cardinfo) != nil:
    result = $snd_ctl_card_info_get_name(cardinfo)

proc driver*(cardinfo: snd_ctl_card_info_t): string =
  if pointer(cardinfo) != nil:
    result = $snd_ctl_card_info_get_driver(cardinfo)

proc `$`*(cardinfo: snd_ctl_card_info_t): string =
  return cardinfo.name & " [" & cardinfo.driver & "]"

proc openMixer*(cardname: string): snd_mixer_t =
  var mixer: snd_mixer_t

  block: # open the mixer interface
    let err = snd_mixer_open(mixer, 0)
    if err < 0:
      echo "Cannot open mixer: ", snd_strerror(err)
      return nil

  block: # attach the mixer interface to the card
    let err = snd_mixer_attach(mixer, cardname)
    if err < 0:
      echo "Cannot attach mixer: ", snd_strerror(err)
      discard snd_mixer_close(mixer)
      return nil

  block: # register the mixer interface
    let err = snd_mixer_selem_register(mixer, nil, nil)
    if err < 0:
      echo "Cannot register mixer interface: ", snd_strerror(err)
      discard snd_mixer_close(mixer)
      return nil

  block: # load the mixer elements
    let err = snd_mixer_load(mixer)
    if err < 0:
      echo "Cannot load mixer elements: ", snd_strerror(err)
      discard snd_mixer_close(mixer)
      return nil

  return mixer

proc closeMixer*(mixer: snd_mixer_t) {.inline.} =
  discard snd_mixer_close(mixer)

iterator items*(mixer: snd_mixer_t): snd_mixer_elem_t {.inline.} =
  if pointer(mixer) != nil:
    var elem: snd_mixer_elem_t = snd_mixer_first_elem(mixer)
    while pointer(elem) != nil:
      yield elem
      elem = snd_mixer_elem_next(elem)

proc index*(elem: snd_mixer_elem_t): uint =
  if pointer(elem) == nil:
    return
  return uint(snd_mixer_selem_get_index(elem))

proc name*(elem: snd_mixer_elem_t): string {.inline.} =
  if pointer(elem) == nil:
    return
  let elem_name = snd_mixer_selem_get_name(elem)
  return $elem_name

proc `$`*(elem: snd_mixer_elem_t): string {.inline.} = name(elem)

proc getMixerElem*(mixer: snd_mixer_t, name: string): snd_mixer_elem_t =
  if pointer(mixer) == nil:
    return nil
  for elem in mixer:
    if elem.name == name:
      return elem

proc getDBVolume*(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL): clong =
  if pointer(elem) == nil:
    return
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    discard snd_mixer_selem_get_playback_dB(elem, channel, result)
  elif snd_mixer_selem_has_capture_volume(elem) != 0:
    discard snd_mixer_selem_get_capture_dB(elem, channel, result)

proc getDBVolumeRange*(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL): tuple[dBmin: clong, dBmax: clong] =
  if pointer(elem) == nil:
    return
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    snd_mixer_selem_get_playback_dB_range(elem, result.dBmin, result.dBmax)
  elif snd_mixer_selem_has_capture_volume(elem) != 0:
    snd_mixer_selem_get_capture_dB_range(elem, result.dBmin, result.dBmax)

proc setDBVolume*(elem: snd_mixer_elem_t, channels: seq[SND_MIXER_CHANNEL], volume: clong, dir: cint = 0) =
  var playbackDevice: bool
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    playbackDevice = true
  elif snd_mixer_selem_has_capture_volume(elem) != 0:
    playbackDevice = false
  else:
    echo "Could not set volume: not a playback or capture device???"
    return  # not a capture device either. abort, abort, abort

  if pointer(elem) == nil:
    return
  for channel in channels:
    let err = if playbackDevice:
      snd_mixer_selem_set_playback_dB(elem, channel, volume, dir)
    else:
      snd_mixer_selem_set_capture_dB(elem, channel, volume, dir)
    if err < 0:
      echo "Could not set volume: ", snd_strerror(err)
      break

proc setDBVolume(elem: snd_mixer_elem_t, volume: clong, dir: cint = 0) =
  if pointer(elem) == nil:
    return
  var err: cint
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    err = snd_mixer_selem_set_playback_dB_all(elem, volume, dir)
  elif snd_mixer_selem_has_capture_volume(elem) != 0:
    err = snd_mixer_selem_set_capture_dB_all(elem, volume, dir)
  else:
    echo "Could not set volume: not a playback or capture device???"
    return  # not a capture device either. abort, abort, abort
  if err < 0:
    echo "Could not set volume: ", snd_strerror(err)

proc setSwitch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL, value: int) =
  if pointer(elem) == nil:
    return
  var err: cint
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    err = snd_mixer_selem_set_playback_switch(elem, channel, cint(value))
  elif snd_mixer_selem_has_capture_volume(elem) != 0:
    err = snd_mixer_selem_set_capture_switch(elem, channel, cint(value))
  if err < 0:
    echo "Could not mute: ", snd_strerror(err)

proc setSwitch(elem: snd_mixer_elem_t, value: int) =
  if pointer(elem) == nil:
    return
  var err: cint
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    err = snd_mixer_selem_set_playback_switch_all(elem, cint(value))
  else:
    err = snd_mixer_selem_set_capture_switch_all(elem, cint(value))
  if err < 0:
    echo "Could not set switch: ", snd_strerror(err)

proc getSwitch(elem: snd_mixer_elem_t, channel: SND_MIXER_CHANNEL): int =
  if pointer(elem) == nil:
    return
  var err, value: cint
  if snd_mixer_selem_has_playback_volume(elem) != 0:
    err = snd_mixer_selem_get_playback_switch(elem, channel, value)
  else:
    err = snd_mixer_selem_get_capture_switch(elem, channel, value)
  if err < 0:
    echo "Could not get switch: ", snd_strerror(err)
  return int(value)

when isMainModule:
  let params = commandLineParams()
  if len(params) == 0 or params[0] notin @["up", "down", "toggle", "mute", "unmute"]:
    quit("Syntax: " & getAppFilename() & " up|down|toggle|mute|unmute")
  let cmd = params[0]
  # find the card we want
  var cardname: string  # eg. hw:0
  for (xcardname, cardinfo) in alsaCards():
    if cardinfo.name == "UMC404HD 192k":
      cardname = xcardname
  if cardname == "":
    quit("Could not find card")

  # open mixer for hw:x
  let mixer = openMixer(cardname)
  if pointer(mixer) == nil:
    quit("Could not open mixer for: " & cardname)

  # find the right selem in mixer
  for elem in mixer:
    if elem.name == "UMC404HD 192k Output":
      let (dbmin, dbmax) = getDBVolumeRange(elem, SND_MIXER_SCHN_FRONT_LEFT)
      var dbvolume = getDBVolume(elem, SND_MIXER_SCHN_FRONT_LEFT)
      let jump = (dbmax-dbmin) div 100
      if cmd == "down":
        dbvolume -= jump
        if dbvolume < dbmin:
          dbvolume = dbmin
        setDBVolume(elem, dbvolume)
      elif cmd == "up":
        dbvolume += jump
        if dbvolume > dbmax:
          dbvolume = dbmax
        setDBVolume(elem, dbvolume)
      elif cmd == "mute":
        setSwitch(elem, 0)
      elif cmd == "unmute":
        setSwitch(elem, 1)
      else:
        if getSwitch(elem, SND_MIXER_SCHN_FRONT_LEFT) == 0:
          setSwitch(elem, 1)
        else:
          setSwitch(elem, 0)
      break  # found matching mixer element, stop
  closeMixer(mixer)
