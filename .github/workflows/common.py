from applib.helm import Helm
from applib.repo import Repo, RepoType
import sys, yaml, os, time, getopt

def template_yaml(manifests, gdir='/output', verbose=False, local_repository=None):
  for app in manifests.keys():
    if verbose>0:
      print('(DEBUG) Generate resource yamls for {}'.format(app))
    manifests[app].toSeperatedResources(gdir, verbose, local_repository)

def install_and_check_done(manifests, install, config, verbose=False, kubeconfig='~/.kube/config'):
  # os.system("helm install -n monstar {} monstarrepo/{} -f vo".format())
  try:
    cinterval=int(config['metadata']['checkInterval'])
  except KeyError:
    cinterval=10
  pending = []
  for chart in install:
    manifests[chart].install(verbose,kubeconfig)
    pending.append(chart)

  while True:
    successed = []
    for chart in pending:
      if manifests[chart].getStatus()=='deployed':
        successed.append(chart)

    for chart in successed:
      pending.remove(chart)

    print("\nWaiting for finish: ")
    print(pending)
    if not pending:
      break
    time.sleep(cinterval)
  return

def load_manifest(fd, local_repository=None, verbose=0):
  manifests = dict()

  for parsed in list(yaml.load_all(fd, Loader=yaml.loader.SafeLoader)):
    if parsed.get('spec') == None:
      print('--- Warn: A invalid resource is given  ---')
      print(parsed)
      print('--- Warn END ---')
      continue
    if parsed['spec']['chart'].get('type')!=None:
      if parsed['spec']['chart'].get('type')=='helmrepo':
        repo = Repo(
          # repotype, repo, chartOrPath, versionOrReference)
          RepoType.HELMREPO,
          parsed['spec']['chart']['repository'],
          parsed['spec']['chart']['name'],
          parsed['spec']['chart']['version'])
      elif parsed['spec']['chart'].get('type')=='git':
        repo = Repo(
          RepoType.GIT,
          parsed['spec']['chart']['git'],
          parsed['spec']['chart']['path'],
          parsed['spec']['chart']['ref'])
      else:
        print('Wrong repo type: {}'.format(parsed['spec']['chart'].get('type')))
    elif parsed['spec']['chart'].get('git')!=None:
      repo = Repo(
        RepoType.GIT,
        parsed['spec']['chart']['git'],
        parsed['spec']['chart']['path'],
        parsed['spec']['chart']['ref'])
    elif parsed['spec']['chart'].get('repository')!=None:
      repo = Repo(
        RepoType.HELMREPO,
        parsed['spec']['chart']['repository'],
        parsed['spec']['chart']['name'],
        parsed['spec']['chart']['version'])
    else:
      print('Wrong repo {0}',parsed)

    if local_repository != None:
      repo.repo = local_repository

    # self, repo, name, namespace, override):
    manifests[parsed['metadata']['name']]=Helm(
      repo,
      parsed['spec']['releaseName'],
      parsed['spec']['targetNamespace'],
      parsed['spec']['values'])

  return manifests

def check_chart_repo(fd, target_repo, except_list=[], verbose=0):
  invalid_dic=dict()

  for parsed in list(yaml.load_all(fd, Loader=yaml.loader.SafeLoader)):
    if (not parsed.get('spec').get('chart').get('repository').startswith(target_repo)) and (parsed.get('spec').get('chart').get('repository') not in except_list) :
      invalid_dic[parsed.get('metadata').get('name')]=parsed.get('spec').get('chart').get('repository')

      if verbose >= 1:
        print('{} is defined with wrong repository: {}'.format(
          parsed.get('metadata').get('name'),
          parsed.get('spec').get('chart').get('repository')))

  return invalid_dic

def check_image_repo(fd, target_repo, except_list=[], verbose=0):
  invalid_dic=dict()

  loaded_manifest=load_manifest(fd)
  if verbose > 0:
    print('(DEBUG) Loaded manifest:', loaded_manifest)
    for key in loaded_manifest.keys():
      print(key, loaded_manifest[key])

  print('size is {} and keys = {}'.format(len(loaded_manifest),loaded_manifest.keys()))


  for key in loaded_manifest.keys():
    invalid_images=[]
    # print(loaded_manifest[key].toString())
    # ilist = loaded_manifest[key].get_image_list(verbose)
    for image_url in loaded_manifest[key].get_image_list(verbose):
    # for image_url in ilist:
      if not image_url.startswith(target_repo):
        invalid_images.append(image_url)
    if(len(invalid_images)>0):
      invalid_dic[key]=invalid_images

  return invalid_dic
