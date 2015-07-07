include (../caQtDM_Viewer/qtdefs.pri)

unix {
  TEMPLATE = subdirs
  SUBDIRS = caQtDM_Lib1
  exists("/home/ACS/Control/Lib/libDEV.so") {
         SUBDIRS += caQtDM_Lib2
  }
}

win32 {
  win32-msvc* {
        DEFINES +=_CRT_SECURE_NO_WARNINGS
        DEFINES += CAQTDM_LIB_LIBRARY
        TEMPLATE = lib
        
        DebugBuild {
                EPICS_LIBS=$$(EPICS_BASE)/lib/$$(EPICS_HOST_ARCH)
                DESTDIR = $(CAQTDM_COLLECT)/debug
                OBJECTS_DIR = debug/obj
                LIBS += $$(QWTHOME)/lib/qwtd.lib
                LIBS += $${EPICS_LIBS}/ca.lib
                LIBS += $${EPICS_LIBS}/COM.lib
                LIBS += $(CAQTDM_COLLECT)/debug/qtcontrols.lib
        }
        ReleaseBuild {
                QMAKE_CXXFLAGS += /Z7
                QMAKE_CFLAGS   += /Z7
                QMAKE_LFLAGS   += /DEBUG /OPT:REF /OPT:ICF
                EPICS_LIBS=$$(EPICS_BASE)/lib/$$(EPICS_HOST_ARCH)
                DESTDIR = $(CAQTDM_COLLECT)
                OBJECTS_DIR = release/obj
                LIBS += $$(QWTHOME)/lib/qwt.lib
                LIBS += $${EPICS_LIBS}/ca.lib
                LIBS += $${EPICS_LIBS}/COM.lib
                LIBS += $(CAQTDM_COLLECT)/qtcontrols.lib
                
        }
   }
   win32-g++ {
        EPICS_LIBS=$$(EPICS_BASE)/lib/win32-x86-mingw
	LIBS += $$(QWTLIB)/libqwt.a
	LIBS += $$(QTCONTROLS_LIBS)/release//libqtcontrols.a
	LIBS += $${EPICS_LIBS}/ca.lib
	LIBS += $${EPICS_LIBS}/COM.lib
	QMAKE_POST_LINK = $${QMAKE_COPY} .\\release\\caQtDM_Lib.dll ..\caQtDM_Binaries
   }

   INCLUDEPATH += $$(EPICS_BASE)/include
   INCLUDEPATH += $$(EPICS_BASE)/include/os/win32
}

MOC_DIR = ./moc
VPATH += ./src
INCLUDEPATH += ./src
UI_DIR += ./
INCLUDEPATH += ../caQtDM_QtControls/src
include (./caQtDM_Lib.pri)
