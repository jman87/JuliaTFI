IntOrFloat = Union{Int, Float64}
VI = Vector{Int}
VF = Vector{Float64}
VIF = Union{Vector{Int}, Vector{Float64}}
VMI = Union{Vector{Int}, Matrix{Int}}
VMIF = Union{Vector{Int}, Vector{Float64}, Matrix{Int}, Matrix{Float64}}


function red2full(I::VI, X::VF)
  nred = length(I)
  nfull = I[nred]

  II = zeros(Int, nfull)
  XX = zeros(Float64, nfull)

  for i = 2:nred
    dx = (X[i] - X[i-1]) / (I[i] - I[i-1])
    II[I[i-1]] = I[i-1]
    XX[I[i-1]] = X[i-1]
    for ii = (I[i-1]+1):(I[i]-1)
      II[ii] = ii
      XX[ii] = XX[ii-1] + dx
    end
    II[I[i]] = I[i]
    XX[I[i]] = X[i]
  end

  return II, XX
end


function block(I::VMI, J::VMI, K::VMI, x::VMIF, y::VMIF, z::VMIF)
  
  I, x = red2full(vec(I), vec(float(x)))
  J, y = red2full(vec(J), vec(float(y)))
  K, z = red2full(vec(K), vec(float(z)))

  ni = length(I)
  nj = length(J)
  nk = length(K)

  X = Array{Float64, 4}(undef, 3, ni, nj, nk)
  X .= 0.0
  U = similar(X)
  V = similar(X)
  W = similar(X)
  UW = similar(X)
  UV = similar(X)
  VW = similar(X)
  UVW = similar(X)

  # for k = 1:nk
  #   for j = 1:nj
  #     for i = 1:ni
  #       X[:,i,j,k] = zeros(3)
  #       U[:,i,j,k] = zeros(3)
  #       V[i,j,k] = zeros(3)
  #       W[i,j,k] = zeros(3)
  #       UW[i,j,k] = zeros(3)
  #       UV[i,j,k] = zeros(3)
  #       VW[i,j,k] = zeros(3)
  #       UVW[i,j,k] = zeros(3)
  #     end
  #   end
  # end

  for k = 1:nk
    for j = 1:nj
      for i = 1:ni
        X[1,i,j,k] = float(x[i])
        X[2,i,j,k] = float(y[j])
        X[3,i,j,k] = float(z[k])
      end
    end
  end

  return X
end

@with_kw struct SphereType
center::VIF
radius::Float64
type::String="SPHERE"
end

function sphere(
  point_x::IntOrFloat, point_y::IntOrFloat, point_z::IntOrFloat,
  radius::IntOrFloat
  )
  return SphereType(
    center=[ Float64(point_x), Float64(point_y), Float64(point_z) ],
    radius=Float64(radius)
  )
end

function project_to_sphere!(ijk::Int, val::Int, X::Array{Float64,4}, sphere::SphereType)

  # Note that for projecting a surface, the 4D array X, is passed to this
  # function as a 3D array, i.e., a surface rather than a volume.

  local Xijk
  if ijk==1
    Xijk = X[:,val,:,:]
  elseif ijk==2
    Xijk = X[:,:,val,:]
  elseif ijk==3
    Xijk = X[:,:,:,val]
  end

  for j = 1:size(Xijk, 3)
    for i = 1:size(Xijk, 2)
      x = Xijk[:,i,j]
      Xijk[:,i,j] = nearest_point_on_sphere(x, sphere)
    end
  end

  if ijk==1
  X[:,val,:,:] = Xijk
  elseif ijk==2
    X[:,:,val,:] = Xijk
  elseif ijk==3
    X[:,:,:,val] = Xijk
  end

  return X
end

function nearest_point_on_sphere(point_p::VF, sphere::SphereType)

  # Compute Point q on Sphere Closest to Point p

  xc = sphere.center[1]
  yc = sphere.center[2]
  zc = sphere.center[3]

  xp = point_p[1]
  yp = point_p[2]
  zp = point_p[3]

  cp = sqrt( (xp-xc)*(xp-xc) + (yp-yc)*(yp-yc) + (zp-zc)*(zp-zc) )

  ratio = sphere.radius / cp

  xq = xc + (ratio * (xp-xc))
  yq = yc + (ratio * (yp-yc))
  zq = zc + (ratio * (zp-zc))
  
  return [xq, yq, zq]
end


# function block(I::VMI, J::VMI, K::VMI, x::VMIF, y::VMIF, z::VMIF)
  
#   I, x = red2full(vec(I), vec(float(x)))
#   J, y = red2full(vec(J), vec(float(y)))
#   K, z = red2full(vec(K), vec(float(z)))

#   ni = length(I)
#   nj = length(J)
#   nk = length(K)

#   X = Array{Vector{Float64}, 3}(undef, ni, nj, nk)
#   U = similar(X)
#   V = similar(X)
#   W = similar(X)
#   UW = similar(X)
#   UV = similar(X)
#   VW = similar(X)
#   UVW = similar(X)
#   for k = 1:nk
#     for j = 1:nj
#       for i = 1:ni
#         X[i,j,k] = zeros(3)
#         U[i,j,k] = zeros(3)
#         V[i,j,k] = zeros(3)
#         W[i,j,k] = zeros(3)
#         UW[i,j,k] = zeros(3)
#         UV[i,j,k] = zeros(3)
#         VW[i,j,k] = zeros(3)
#         UVW[i,j,k] = zeros(3)
#       end
#     end
#   end

#   for k = 1:nk
#     for j = 1:nj
#       for i = 1:ni
#         X[i,j,k][1] = float(x[i])
#         X[i,j,k][2] = float(y[j])
#         X[i,j,k][3] = float(z[k])
#       end
#     end
#   end

#   return X
# end