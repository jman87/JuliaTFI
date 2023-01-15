using JuliaTFI
using WriteVTK

X = block(
    [1, 3], [1, 3],  [1, 3],
    [0, 4], [-2, 2], [-2, 2]
)

sd1 = sphere(0,0,0, 8)

println("BEFORE"); display(X)

Y = project_to_sphere!(1, size(X,2), X, sd1)

println("AFTER"); display(X)
println("Y"); display(Y)

vtkfile = vtk_grid("vtk01", X)
outfiles = vtk_save(vtkfile)
