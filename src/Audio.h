#ifndef AUDIO_H
#define AUDIO_H

#include <ruby.h>
#include <SDL.h>

extern VALUE rb_mAudio;
void Init_Audio(void);

void initAudioSDL(void);
void deinitAudioSDL(void);

#endif /* AUDIO_H */
