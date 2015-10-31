function dist=KLdistanceNormal(GMModel)

mu0=GMModel.mu(1,:)';
mu1=GMModel.mu(2,:)';

sg0=GMModel.Sigma(:,:,1);
sg1=GMModel.Sigma(:,:,2);

k=2;
dist=(trace(inv(sg1)*sg0)+(mu1-mu0)'*inv(sg1)*(mu1-mu0)-k-log(det(sg0)/det(sg1)))/2;

end