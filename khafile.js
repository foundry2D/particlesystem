let project = new Project('Particle System');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('Libraries/zui');
resolve(project);
