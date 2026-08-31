// Ray-Sphere Intersection Acceleration Unit
module ray_sphere_intersector (
    input  logic signed [31:0] ray_orig_x, ray_orig_y, ray_orig_z,
    input  logic signed [31:0] ray_dir_x,  ray_dir_y,  ray_dir_z,
    input  logic signed [31:0] sph_cntr_x, sph_cntr_y, sph_cntr_z,
    input  logic signed [31:0] radius_sq,

    output logic signed [63:0] v_dot_d_out,
    output logic signed [63:0] disc_out,
    output logic               hit_out
);
    // Vector v = center - origin
    logic signed [31:0] vx, vy, vz;
    assign vx = sph_cntr_x - ray_orig_x;
    assign vy = sph_cntr_y - ray_orig_y;
    assign vz = sph_cntr_z - ray_orig_z;

    // Parallel dot products
    logic signed [63:0] v_dot_d, v_dot_v;
    assign v_dot_d = (vx * ray_dir_x) + (vy * ray_dir_y) + (vz * ray_dir_z);
    assign v_dot_v = (vx * vx) + (vy * vy) + (vz * vz);

    // Discriminant formula
    logic signed [63:0] discriminant;
    assign discriminant = (v_dot_d * v_dot_d) - (v_dot_v - radius_sq);

    // Outputs
    assign v_dot_d_out = v_dot_d;
    assign disc_out    = discriminant;
    assign hit_out     = (discriminant >= 0);
endmodule
