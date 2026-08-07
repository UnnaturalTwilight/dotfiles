from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, draw_title, as_rgb
from kitty.utils import color_as_int

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_title_length: int, index: int, is_last: bool,
    extra_data: ExtraData
) -> int:
    orig_fg = screen.cursor.fg
    orig_bg = screen.cursor.bg
    left_sep, right_sep = ('', '')

    def draw_sep(which: str) -> None:
        screen.cursor.bg = as_rgb(color_as_int(draw_data.default_bg))
        screen.cursor.fg = orig_bg
        screen.draw(which)
        screen.cursor.bg = orig_bg
        screen.cursor.fg = orig_fg

    draw_sep(left_sep)
    if tab.tab_id < 0:
        # "fake" tab (new tab button, etc.)
        screen.draw(f" {tab.title} ")
    elif max_title_length <= 5:
        screen.draw(f'#{index}')
    else:
        draw_title(draw_data, screen, tab, index)
        extra = screen.cursor.x - before - max_title_length
        print("extra:%d" %(extra))
        if extra >= 0:
            screen.cursor.x -= extra + 3
            screen.draw('… ')
        elif extra == -1:
            screen.cursor.x -= 2
            screen.draw('…')
    draw_sep(right_sep)
    draw_sep(' ')

    return screen.cursor.x
