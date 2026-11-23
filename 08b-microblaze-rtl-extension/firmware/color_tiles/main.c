#include "../framebuffer.h"

enum {
    TILE_SIZE = 12,
    TILES_PER_ROW = FRAME_WIDTH / TILE_SIZE
};

int main(void)
{
    for (unsigned int y = 0; y < FRAME_HEIGHT; ++y) {
        unsigned int first_tile = (y / TILE_SIZE) * TILES_PER_ROW;

        for (unsigned int word = 0; word < FRAME_WORDS_PER_ROW; ++word) {
            unsigned int tile = word * PIXELS_PER_WORD / TILE_SIZE;
            uint8_t color = (uint8_t)(first_tile + tile);

            framebuffer_write(word, y, framebuffer_pack(color, color, color, color));
        }
    }

    for (;;) {
        /* The video controller keeps displaying the frame. */
    }
}
