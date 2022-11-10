using JuliaTFI
using WriteVTK

X = block([1, 5], [1, 9],  [1, 4],
          [0, 4], [-2, 2], [-1, 1])

vtkfile = vtk_grid("vtk01", X)
outfiles = vtk_save(vtkfile)
