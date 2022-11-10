IntOrFloat = Union{Int, Float64}
VI = Vector{Int}
VF = Vector{Float64}
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