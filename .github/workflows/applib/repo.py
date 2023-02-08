from enum import Enum, unique
import sys, yaml, os, time, getopt

@unique
class RepoType(Enum):
  HELMREPO=1
  GIT=2
  LOCAL=3

class Repo:
# Will Make When it's needed
  def __init__(self):
    self.list=[]

  def __init__(self, repotype, repo, chartOrPath, versionOrReference):
    self.repotype = repotype
    self.repo = repo
    self.chartOrPath = chartOrPath
    self.versionOrReference = versionOrReference

  def toString(self):
    return '[REPO: {}, {}, {}, {}]'.format(    self.repotype,
      self.repo,
      self.chartOrPath,
      self.versionOrReference )
  
  def version(self):
    if self.repotype == RepoType.HELMREPO:
      return self.versionOrReference
    else: 
      return None

  def reference(self):
    if self.repotype == RepoType.GIT:
      return self.versionOrReference
    else: 
      return None

  def chart(self):
    if self.repotype == RepoType.HELMREPO:
      return self.chartOrPath
    else: 
      return None
  def path(self):
    if self.repotype == RepoType.GIT:
      return self.chartOrPath
    else: 
      return None

  def repository(self):
    return self.repo
  
  def getUrl(self):
    if self.repotype == RepoType.GIT and self.repo.startswith('git@'):
      if self.repo.endswith('.git'):
        return self.repo.replace(':','/').replace('git@','https://')
      else:
        return self.repo.replace(':','/').replace('git@','https://')+'.git'

    if self.repotype == RepoType.GIT:
      return self.repo
    else:
      return None