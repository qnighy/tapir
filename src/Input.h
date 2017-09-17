#ifndef INPUT_H
#define INPUT_H

#include <ruby.h>
#include <SDL.h>

extern VALUE rb_mInput;
void Init_Input(void);

void keyPressed(SDL_Keycode key);
void keyReleased(SDL_Keycode key);

#endif /* INPUT_H */
