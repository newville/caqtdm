/*
 *  This file is part of the caQtDM Framework, developed at the Paul Scherrer Institut,
 *  Villigen, Switzerland
 *
 *  The caQtDM Framework is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  The caQtDM Framework is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the caQtDM Framework.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Copyright (c) 2010 - 2014
 *
 *  Author:
 *    Anton Mezger
 *  Contact details:
 *    anton.mezger@psi.ch
 */
#ifndef ArchiverCommon_H
#define ArchiverCommon_H

#include <QObject>
#include <QMap>
#include <QMutex>
#include <QList>
#include <QTimer>
#include <QThread>
#include <qwt.h>
#include "cacartesianplot.h"
#include "mutexKnobData.h"
#include "MessageWindow.h"

struct indexes {QString key; int indexX; int indexY; int secondsPast; QString pv; int updateSeconds; struct timeb lastUpdateTime; QWidget *w; int nrOfBins; QMutex *mutexP; bool init;};


class Q_DECL_EXPORT ArchiverCommon : public QObject
{
    Q_OBJECT

public:
    ArchiverCommon();

    int initCommunicationLayer(MutexKnobData *data, MessageWindow *messageWindow, QMap<QString, QString> options);
    int pvAddMonitor(int index, knobData *kData, int rate, int skip);
    int pvClearMonitor(knobData *kData);
    int pvFreeAllocatedData(knobData *kData);
    int TerminateIO() {return true;}
    //struct indexes {int indexX; int indexY; QString archive; int secondspast; QString pv;};
    void updateCartesian(int nbVal, indexes indexNew, QVector<double> TimerN, QVector<double> YValsN);

protected:

signals:
    void Signal_UpdateInterface(QMap<QString, indexes> listOfIndexes);

private slots:
    void updateInterface();

private:
    typedef struct  {char Dev[40];} device;
    QMutex mutex;
    QMutex *mutexP;
    MutexKnobData *mutexknobdataP;
    MessageWindow *messagewindowP;

    QMap<QString, indexes> listOfIndexes;

    QTimer *timer;
    bool timerRunning;
};



#endif
