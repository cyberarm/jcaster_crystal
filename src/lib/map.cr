TEXTURE_WIDTH  = 64
TEXTURE_HEIGHT = 64

class Map
  getter :init

  def initialize(window : JCaster)
    @window = window

    @map = Gosu.record(@window.image_width.to_i, @window.image_height.to_i) { }
    @bg = Gosu.record(@window.image_width.to_i, @window.image_height.to_i) do
      sky_c = Gosu::Color.argb(0xFF86A0D9)
      sky_c2 = Gosu::Color.argb(0xFF86A084)
      flr_c = Gosu::Color.argb(0xFF343434)
      Gosu.draw_quad(0, 0, sky_c, @window.image_width.to_i, 0, sky_c, 0, (@window.image_height >> 1).to_i, sky_c2, @window.image_width.to_i, (@window.image_height >> 1).to_i, sky_c2)
      Gosu.draw_quad(0, (@window.image_height >> 1).to_i, flr_c, @window.image_width.to_i, (@window.image_height >> 1).to_i, flr_c, 0, @window.image_height.to_i, flr_c, @window.image_width.to_i, @window.image_height.to_i, flr_c)
    end

    @wallset = [Gosu::Image.load_tiles("#{ROOT_PATH}/media/walls.png", 1, TEXTURE_HEIGHT, tileable: true, retro: true), # see what I did there?
                Gosu::Image.load_tiles("#{ROOT_PATH}/media/wallsd.png", 1, TEXTURE_HEIGHT, tileable: true, retro: true)]

    @init = true
  end

  def update
    @map = Gosu.record(@window.image_width.to_i, @window.image_height.to_i) do
      (0..@window.image_width).each do |x|
        camera_x = 2*x.to_f / (@window.image_width) - 1
        ray_pos_x = @window.player.not_nil!.pos_x
        ray_pos_y = @window.player.not_nil!.pos_y
        ray_dir_x = @window.player.not_nil!.dir_x + @window.player.not_nil!.plane_x * camera_x
        ray_dir_y = @window.player.not_nil!.dir_y + @window.player.not_nil!.plane_y * camera_x

        map_x = ray_pos_x.to_i
        map_y = ray_pos_y.to_i

        delta_dist_x = Math.sqrt(1 + (ray_dir_y * ray_dir_y) / (ray_dir_x * ray_dir_x))
        delta_dist_y = Math.sqrt(1 + (ray_dir_x * ray_dir_x) / (ray_dir_y * ray_dir_y))

        hit = false

        if ray_dir_x < 0
          step_x = -1
          side_dist_x = (ray_pos_x - map_x) * delta_dist_x
        else
          step_x = 1
          side_dist_x = (map_x + 1.0 - ray_pos_x) * delta_dist_x
        end

        if ray_dir_y < 0
          step_y = -1
          side_dist_y = (ray_pos_y - map_y) * delta_dist_y
        else
          step_y = 1
          side_dist_y = (map_y + 1.0 - ray_pos_y) * delta_dist_y
        end

        side = 0
        while !hit
          if side_dist_x < side_dist_y
            side_dist_x += delta_dist_x
            map_x += step_x
            side = 0
          else
            side_dist_y += delta_dist_y
            map_y += step_y
            side = 1
          end
          hit = true if WORLD_MAP[map_x][map_y] > 0
        end

        if side == 0
          perp_wall_dist = ((map_x - ray_pos_x + (1 - step_x) / 2) / ray_dir_x).abs
        else
          perp_wall_dist = ((map_y - ray_pos_y + (1 - step_y) / 2) / ray_dir_y).abs
        end

        line_height = (@window.image_height/perp_wall_dist).abs

        draw_start = -line_height/2 + @window.image_height/2
        # draw_end = line_height/2 + @window.image_height/2

        if side == 1
          wall_x = ray_pos_x + ((map_y - ray_pos_y + (1 - step_y)/2)/ray_dir_y)*ray_dir_x
        else
          wall_x = ray_pos_y + ((map_x - ray_pos_x + (1 - step_x)/2)/ray_dir_x)*ray_dir_y
        end

        wall_x = wall_x - wall_x.to_i

        tex_x = (wall_x*TEXTURE_WIDTH).to_i
        tex_x = TEXTURE_WIDTH - tex_x - 1 if (side == 0 && ray_dir_x > 0)
        tex_x = TEXTURE_WIDTH - tex_x - 1 if (side == 1 && ray_dir_y < 0)

        @wallset[side][((WORLD_MAP[map_x][map_y] - 1) * TEXTURE_WIDTH) + tex_x].draw(x, draw_start, 1, 1.0, line_height.to_f / (TEXTURE_HEIGHT))
      end
    end
  end

  def draw
    @bg.draw(0, 0, 0, Gosu.screen_width.to_f / (@window.image_width), Gosu.screen_height.to_f / (@window.image_height))
    @map.draw(0, 0, 1, Gosu.screen_width.to_f / (@window.image_width), Gosu.screen_height.to_f / (@window.image_height))
  end
end
